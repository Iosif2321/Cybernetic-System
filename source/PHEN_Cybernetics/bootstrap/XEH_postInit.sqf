if (!hasInterface) exitWith {};

PHEN_CS_CSS_MineRadius = 50;
PHEN_CS_CSS_AllyRange = 1000;
PHEN_CS_CSS_CloseRadius = 10;
PHEN_CS_CSS_NearFOVRange = 100;
PHEN_CS_CSS_NearFOVDegrees = 110;
PHEN_CS_CSS_NearFOVDot = cos (PHEN_CS_CSS_NearFOVDegrees / 2);
PHEN_CS_CSS_FarFOVDegrees = 90;
PHEN_CS_CSS_FarFOVDot = cos (PHEN_CS_CSS_FarFOVDegrees / 2);
PHEN_CS_CSS_RadarScaleLevels = [250,500,1000,2000];
PHEN_CS_CSS_RadarRingFractions = [0.5,1];
PHEN_CS_CSS_MinAimSolutionDistance = 15;
PHEN_CS_CSS_MaxRadarContacts = 32;
PHEN_CS_CSS_AimSolution = [];
PHEN_CS_CSS_FriendContacts = [];
PHEN_CS_CSS_MineContacts = [];
PHEN_CS_CSS_RadarContacts = [];
PHEN_CS_CSS_FocusActive = false;
PHEN_CS_CSS_FocusKeyNames = [];

PHEN_CS_fnc_CSS_getUnit = {
    private _unit = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];
    if (isNull _unit) then { _unit = player; };
    _unit
};

PHEN_CS_fnc_CSS_hasSuite = {
    private _unit = call PHEN_CS_fnc_CSS_getUnit;
    (!isNull _unit) && { alive _unit } && { _unit getVariable ["PHEN_CS_Abillity_CombatSensorSuite", false] }
};

PHEN_CS_fnc_CSS_getHudLayout = {
    private _hudScale = ((missionNamespace getVariable ["PHEN_CS_CSS_HudScale", 1]) max 0.5) min 2;
    private _textScale = 0.88 + ((_hudScale - 1) * 0.12);
    private _panelW = (0.22 * _hudScale) min 0.34;
    private _panelH = (0.235 * _hudScale) min 0.36;
    private _panelX = safeZoneX + safeZoneW - (0.015 + _panelW);
    private _panelY = safeZoneY + safeZoneH - (0.06 + _panelH);
    private _centerX = _panelX + (_panelW * 0.5);
    private _centerY = _panelY + (_panelH * 0.63);
    private _radius = (_panelW min _panelH) * 0.38;
    private _dotBase = 0.011 * ((_hudScale max 0.75) min 1.45);
    private _noseOffset = 0.012 * ((_hudScale max 0.75) min 1.45);
    [_hudScale, _panelX, _panelY, _panelW, _panelH, _centerX, _centerY, _radius, _dotBase, _noseOffset, _textScale]
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

PHEN_CS_fnc_CSS_getMarkerPosASL = {
    params ["_object", ["_isMine", false]];
    if (isNull _object) exitWith { [] };

    private _offsetZ = 1.2;
    if (_isMine) then {
        _offsetZ = 0.35;
    } else {
        if (_object isKindOf "CAManBase") then {
            _offsetZ = 2.15;
        } else {
            if (_object isKindOf "Air") then {
                _offsetZ = 5.0;
            } else {
                _offsetZ = 3.0;
            };
        };
    };

    AGLToASL (_object modelToWorldVisual [0,0,_offsetZ])
};

PHEN_CS_fnc_CSS_getViewDirection = {
    params ["_unit"];

    private _dir = vectorNormalized (eyeDirection _unit);
    if ((vectorMagnitude _dir) <= 0.001) then { _dir = vectorNormalized (vectorDirVisual _unit); };
    if ((vectorMagnitude _dir) <= 0.001) then { _dir = [0,1,0]; };

    _dir
};

PHEN_CS_fnc_CSS_isMarkerVisible = {
    params ["_unit", "_object", "_targetASL", ["_range", PHEN_CS_CSS_AllyRange]];

    if (isNull _unit || { !alive _unit }) exitWith { false };
    if ((count _targetASL) < 3) exitWith { false };
    private _distance = getPosASL _unit distance _targetASL;
    if (_distance > _range) exitWith { false };
    if (_distance <= PHEN_CS_CSS_CloseRadius) exitWith { true };

    private _viewOriginASL = eyePos _unit;
    private _viewDir = [_unit] call PHEN_CS_fnc_CSS_getViewDirection;
    private _toTarget = _targetASL vectorDiff _viewOriginASL;
    if ((vectorMagnitude _toTarget) <= 0.1) exitWith { false };

    private _forwardDot = _viewDir vectorDotProduct (vectorNormalized _toTarget);
    if (_forwardDot <= 0) exitWith { false };
    if (_distance <= PHEN_CS_CSS_NearFOVRange && { _forwardDot < PHEN_CS_CSS_NearFOVDot }) exitWith { false };

    if (_distance > PHEN_CS_CSS_NearFOVRange) then {
        if (_forwardDot < PHEN_CS_CSS_FarFOVDot) exitWith { false };
        private _screen = worldToScreen (ASLToAGL _targetASL);
        if (_screen isEqualTo []) exitWith { false };
        _screen params ["_screenX", "_screenY"];
        private _edge = 0.025;
        if (_screenX < _edge || { _screenX > (1 - _edge) } || { _screenY < _edge } || { _screenY > (1 - _edge) }) exitWith { false };
    };

    private _visibility = [_unit, "VIEW", _object] checkVisibility [_viewOriginASL, _targetASL];
    _visibility > 0.18
};

PHEN_CS_fnc_CSS_isAimVisible = {
    params ["_unit", "_targetASL", ["_range", 5000]];

    if (isNull _unit || { !alive _unit }) exitWith { false };
    if ((count _targetASL) < 3) exitWith { false };
    if ((getPosASL _unit distance _targetASL) > _range) exitWith { false };

    private _viewOriginASL = eyePos _unit;
    private _viewDir = [_unit] call PHEN_CS_fnc_CSS_getViewDirection;
    private _toTarget = _targetASL vectorDiff _viewOriginASL;
    if ((vectorMagnitude _toTarget) <= 0.1) exitWith { false };
    if ((_viewDir vectorDotProduct (vectorNormalized _toTarget)) <= 0) exitWith { false };

    private _screen = worldToScreen (ASLToAGL _targetASL);
    if (_screen isEqualTo []) exitWith { false };
    true
};

PHEN_CS_fnc_CSS_filterVisibleContacts = {
    params ["_unit", "_candidates", "_range", ["_isMine", false]];

    private _filtered = [];
    {
        if (!isNull _x) then {
            private _posASL = [_x, _isMine] call PHEN_CS_fnc_CSS_getMarkerPosASL;
            if ([_unit, _x, _posASL, _range] call PHEN_CS_fnc_CSS_isMarkerVisible) then {
                _filtered pushBack [_x, _posASL];
            };
        };
    } forEach _candidates;

    _filtered
};

PHEN_CS_fnc_CSS_getDisplayName = {
    params ["_object", ["_isMine", false]];
    if (_isMine) exitWith { "MINE" };
    if (isNull _object) exitWith { "CONTACT" };
    if (_object isKindOf "CAManBase") exitWith { name _object };

    private _displayName = getText (configFile >> "CfgVehicles" >> typeOf _object >> "displayName");
    if (_displayName isEqualTo "") then { _displayName = typeOf _object; };
    _displayName
};

PHEN_CS_fnc_CSS_classifyContact = {
    params ["_object", ["_isMine", false]];

    private _icon = "\a3\ui_f\data\map\markers\nato\b_unknown.paa";
    if (_isMine) exitWith { ["MINE", _icon, [1,0.16,0.08,0.95], 0.75] };
    if (isNull _object) exitWith { ["OBJ", _icon, [0.7,0.8,0.9,0.8], 0.6] };

    private _displayName = getText (configFile >> "CfgVehicles" >> typeOf _object >> "displayName");
    private _vehicleClass = getText (configFile >> "CfgVehicles" >> typeOf _object >> "vehicleClass");
    private _typeInfo = toLower (format ["%1 %2 %3", typeOf _object, _displayName, _vehicleClass]);

    if (_object isKindOf "CAManBase") exitWith { ["INF", "\a3\ui_f\data\map\markers\nato\b_inf.paa", [0.15,0.95,0.75,0.9], 0.78] };
    if (unitIsUAV _object) exitWith { ["UAV", "\a3\ui_f\data\map\markers\nato\b_uav.paa", [0.45,0.85,1,0.88], 0.72] };
    if (_object isKindOf "Air") exitWith { ["AIR", "\a3\ui_f\data\map\markers\nato\b_air.paa", [0.35,0.7,1,0.88], 0.82] };
    if (_object isKindOf "StaticWeapon") exitWith { ["STA", "\a3\ui_f\data\map\markers\nato\b_installation.paa", [1,0.88,0.25,0.88], 0.7] };

    if (_object isKindOf "Tank") then {
        if (((_typeInfo find "apc") >= 0) || { (_typeInfo find "btr") >= 0 } || { (_typeInfo find "ifv") >= 0 } || { (_object isKindOf "Wheeled_APC_F") }) exitWith {
            ["APC", "\a3\ui_f\data\map\markers\nato\b_mech_inf.paa", [1,0.68,0.28,0.9], 0.82]
        };
        ["TNK", "\a3\ui_f\data\map\markers\nato\b_armor.paa", [1,0.46,0.22,0.92], 0.95]
    } else {
        if (_object isKindOf "LandVehicle") exitWith { ["VEH", "\a3\ui_f\data\map\markers\nato\b_motor_inf.paa", [0.35,1,0.52,0.86], 0.76] };
        ["OBJ", _icon, [0.7,0.8,0.9,0.8], 0.6]
    }
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

PHEN_CS_fnc_CSS_updateRadarRings = {
    params ["_centerX", "_centerY", "_radius", "_hudScale"];

    private _parts = ["Top", "Bottom", "Left", "Right"];
    private _line = (0.0012 * ((_hudScale max 0.7) min 1.3)) max 0.0008;

    {
        private _ringIndex = _forEachIndex;
        private _fraction = _x;
        private _half = _radius * _fraction;
        private _size = _half * 2;
        private _x0 = _centerX - _half;
        private _y0 = _centerY - _half;
        private _ringAlpha = if (_fraction >= 1) then { 0.26 } else { 0.14 };

        {
            private _ctrl = uiNamespace getVariable [format ["PHEN_CS_CSS_RadarRing_%1_%2", _ringIndex, _x], controlNull];
            if (!isNull _ctrl) then {
                private _pos = switch (_x) do {
                    case "Top": { [_x0, _y0, _size, _line] };
                    case "Bottom": { [_x0, _y0 + _size - _line, _size, _line] };
                    case "Left": { [_x0, _y0, _line, _size] };
                    default { [_x0 + _size - _line, _y0, _line, _size] };
                };

                _ctrl ctrlSetPosition _pos;
                _ctrl ctrlSetBackgroundColor [0.2, 0.85, 1, _ringAlpha];
                _ctrl ctrlShow true;
                _ctrl ctrlCommit 0;
            };
        } forEach _parts;
    } forEach PHEN_CS_CSS_RadarRingFractions;
};

PHEN_CS_fnc_CSS_ensureHud = {
    if (!isNull (uiNamespace getVariable ["PHEN_CS_CSS_BGCtrl", controlNull])) exitWith {};

    private _display = findDisplay 46;
    if (isNull _display) exitWith {};

    private _layout = call PHEN_CS_fnc_CSS_getHudLayout;
    _layout params ["_hudScale", "_panelX", "_panelY", "_panelW", "_panelH", "_centerX", "_centerY", "_radius", "_dotBase", "_noseOffset", "_textScale"];

    private _bg = _display ctrlCreate ["RscText", -1];
    _bg ctrlSetPosition [_panelX, _panelY, _panelW, _panelH];
    _bg ctrlSetBackgroundColor [0, 0.04, 0.06, 0.42];
    _bg ctrlCommit 0;

    private _text = _display ctrlCreate ["RscStructuredText", -1];
    _text ctrlSetPosition [_panelX + 0.008, _panelY + 0.006, _panelW - 0.016, 0.078 * _textScale];
    _text ctrlSetBackgroundColor [0, 0, 0, 0];
    _text ctrlSetStructuredText parseText "";
    _text ctrlCommit 0;

    private _center = _display ctrlCreate ["RscText", -1];
    _center ctrlSetPosition [_centerX - (0.003 * _hudScale), _centerY - (0.003 * _hudScale), 0.006 * _hudScale, 0.006 * _hudScale];
    _center ctrlSetBackgroundColor [0.2, 0.85, 1, 0.9];
    _center ctrlCommit 0;

    {
        private _ringIndex = _forEachIndex;
        {
            private _ring = _display ctrlCreate ["RscText", -1];
            _ring ctrlSetPosition [_centerX, _centerY, 0, 0];
            _ring ctrlSetBackgroundColor [0.2, 0.85, 1, 0.12];
            _ring ctrlShow false;
            _ring ctrlCommit 0;
            uiNamespace setVariable [format ["PHEN_CS_CSS_RadarRing_%1_%2", _ringIndex, _x], _ring];
        } forEach ["Top", "Bottom", "Left", "Right"];
    } forEach PHEN_CS_CSS_RadarRingFractions;

    for "_i" from 0 to (PHEN_CS_CSS_MaxRadarContacts - 1) do {
        private _dot = _display ctrlCreate ["RscPictureKeepAspect", -1];
        _dot ctrlSetPosition [_centerX, _centerY, _dotBase, _dotBase];
        _dot ctrlSetText "\a3\ui_f\data\map\markers\nato\b_unknown.paa";
        _dot ctrlSetTextColor [0.2, 1, 0.55, 0.85];
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

    {
        private _ringIndex = _forEachIndex;
        {
            private _key = format ["PHEN_CS_CSS_RadarRing_%1_%2", _ringIndex, _x];
            private _ctrl = uiNamespace getVariable [_key, controlNull];
            if (!isNull _ctrl) then { ctrlDelete _ctrl; };
            uiNamespace setVariable [_key, nil];
        } forEach ["Top", "Bottom", "Left", "Right"];
    } forEach PHEN_CS_CSS_RadarRingFractions;

    for "_i" from 0 to (PHEN_CS_CSS_MaxRadarContacts - 1) do {
        private _key = format ["PHEN_CS_CSS_RadarDot_%1", _i];
        private _ctrl = uiNamespace getVariable [_key, controlNull];
        if (!isNull _ctrl) then { ctrlDelete _ctrl; };
        uiNamespace setVariable [_key, nil];
    };
};

PHEN_CS_fnc_CSS_updateHud = {
    if !(call PHEN_CS_fnc_CSS_hasSuite) exitWith {
        call PHEN_CS_fnc_CSS_deleteHud;
    };

    call PHEN_CS_fnc_CSS_ensureHud;

    private _unit = call PHEN_CS_fnc_CSS_getUnit;
    private _contacts = call PHEN_CS_fnc_CSS_getFriendObjects;
    private _mines = allMines select { !isNull _x && { _unit distance _x <= PHEN_CS_CSS_MineRadius } };
    call PHEN_CS_fnc_CSS_applyNativeFocusState;
    PHEN_CS_CSS_FriendContacts = [_unit, _contacts, PHEN_CS_CSS_AllyRange] call PHEN_CS_fnc_CSS_filterVisibleContacts;
    PHEN_CS_CSS_MineContacts = [_unit, _mines, PHEN_CS_CSS_MineRadius, true] call PHEN_CS_fnc_CSS_filterVisibleContacts;
    PHEN_CS_CSS_RadarContacts = PHEN_CS_CSS_FriendContacts apply { _x # 0 };

    private _mineCount = count PHEN_CS_CSS_MineContacts;
    private _textCtrl = uiNamespace getVariable ["PHEN_CS_CSS_TextCtrl", controlNull];
    private _scaleIndex = missionNamespace getVariable ["PHEN_CS_CSS_RadarScaleIndex", 2];
    _scaleIndex = (_scaleIndex max 0) min ((count PHEN_CS_CSS_RadarScaleLevels) - 1);
    private _radarRange = PHEN_CS_CSS_RadarScaleLevels # _scaleIndex;
    private _focusText = if (PHEN_CS_CSS_FocusActive) then { " | FOCUS" } else { "" };
    private _layout = call PHEN_CS_fnc_CSS_getHudLayout;
    _layout params ["_hudScale", "_panelX", "_panelY", "_panelW", "_panelH", "_centerX", "_centerY", "_radius", "_dotBase", "_noseOffset", "_textScale"];

    if (!isNull _textCtrl) then {
        _textCtrl ctrlSetStructuredText parseText format [
            "<t size='%6' color='#66ccff'>ARGUS COMBAT OPTICS</t><br/><t size='%7'>%1</t><br/><t size='%8'>RADAR %2m | ALLIES %3 | MINES %4%5</t>",
            call PHEN_CS_fnc_CSS_getVitalsText,
            _radarRange,
            count PHEN_CS_CSS_FriendContacts,
            _mineCount,
            _focusText,
            0.72 * _textScale,
            0.56 * _textScale,
            0.52 * _textScale
        ];
        _textCtrl ctrlSetPosition [_panelX + 0.008, _panelY + 0.006, _panelW - 0.016, 0.078 * _textScale];
        _textCtrl ctrlCommit 0;
    };

    private _bgCtrl = uiNamespace getVariable ["PHEN_CS_CSS_BGCtrl", controlNull];
    if (!isNull _bgCtrl) then {
        _bgCtrl ctrlSetPosition [_panelX, _panelY, _panelW, _panelH];
        _bgCtrl ctrlCommit 0;
    };
    private _centerCtrl = uiNamespace getVariable ["PHEN_CS_CSS_CenterCtrl", controlNull];
    if (!isNull _centerCtrl) then {
        _centerCtrl ctrlSetPosition [_centerX - (0.003 * _hudScale), _centerY - (0.003 * _hudScale), 0.006 * _hudScale, 0.006 * _hudScale];
        _centerCtrl ctrlCommit 0;
    };
    [_centerX, _centerY, _radius, _hudScale] call PHEN_CS_fnc_CSS_updateRadarRings;
    private _bearing = getDirVisual _unit;

    for "_i" from 0 to (PHEN_CS_CSS_MaxRadarContacts - 1) do {
        private _dot = uiNamespace getVariable [format ["PHEN_CS_CSS_RadarDot_%1", _i], controlNull];
        if (!isNull _dot) then { _dot ctrlShow false; };
    };

    private _radarList = [];
    {
        private _distance = _unit distance _x;
        if (_distance <= _radarRange) then {
            _radarList pushBack [_distance, _x];
        };
    } forEach PHEN_CS_CSS_RadarContacts;
    _radarList sort true;
    if ((count _radarList) > PHEN_CS_CSS_MaxRadarContacts) then { _radarList resize PHEN_CS_CSS_MaxRadarContacts; };

    {
        _x params ["_distance", "_contact"];
        private _classification = [_contact] call PHEN_CS_fnc_CSS_classifyContact;
        _classification params ["_code", "_icon", "_color", "_sizeFactor"];

        if (_forEachIndex < PHEN_CS_CSS_MaxRadarContacts) then {
            private _dot = uiNamespace getVariable [format ["PHEN_CS_CSS_RadarDot_%1", _forEachIndex], controlNull];
            if (!isNull _dot) then {
                private _relativeBearing = (_unit getDir _contact) - _bearing;
                private _angle = _relativeBearing * 0.0174533;
                private _scaled = (_distance / _radarRange) min 1;
                private _dotSize = (_dotBase + (_dotBase * _sizeFactor)) max 0.012;
                private _iconRadius = (_radius - (_dotSize * 0.55)) max (_radius * 0.2);
                private _dotX = _centerX + ((sin _angle) * _scaled * _iconRadius);
                private _dotY = _centerY - ((cos _angle) * _scaled * _iconRadius);
                private _headingAngle = (getDirVisual _contact) - _bearing;
                _dot ctrlSetText _icon;
                _dot ctrlSetTextColor _color;
                _dot ctrlSetAngle [_headingAngle, 0.5, 0.5];
                _dot ctrlSetPosition [_dotX - (_dotSize * 0.5), _dotY - (_dotSize * 0.5), _dotSize, _dotSize];
                _dot ctrlShow true;
                _dot ctrlCommit 0;
            };
        };
    } forEach _radarList;
};

PHEN_CS_fnc_CSS_isLauncherWeapon = {
    params ["_unit", "_weapon", "_ammoCfg"];

    private _simulation = toLower (getText (_ammoCfg >> "simulation"));
    (_weapon isEqualTo (secondaryWeapon _unit))
        || { (_simulation find "shotrocket") >= 0 }
        || { (_simulation find "shotmissile") >= 0 }
        || { (_simulation find "shotgrenade") >= 0 }
};

PHEN_CS_fnc_CSS_getMuzzleCfg = {
    params ["_weapon", "_muzzle", "_mode"];

    private _weaponCfg = configFile >> "CfgWeapons" >> _weapon;
    private _muzzleCfg = _weaponCfg;
    if !(_muzzle in ["", _weapon, "this"]) then {
        private _candidate = _weaponCfg >> _muzzle;
        if (isClass _candidate) then { _muzzleCfg = _candidate; };
    };

    private _modeCfg = _muzzleCfg >> _mode;
    if !(isClass _modeCfg) then { _modeCfg = _muzzleCfg; };

    [_weaponCfg, _muzzleCfg, _modeCfg]
};

PHEN_CS_fnc_CSS_getAimRay = {
    params ["_unit", "_weapon"];

    private _startASL = eyePos _unit;
    private _weaponVector = vectorNormalized (_unit weaponDirection _weapon);
    private _fromWeapon = (vectorMagnitude _weaponVector) > 0.001;
    private _aimDir = _weaponVector;

    if (!_fromWeapon) then {
        _aimDir = [_unit] call PHEN_CS_fnc_CSS_getViewDirection;
    };

    [_startASL, _aimDir, _weaponVector, _fromWeapon]
};

PHEN_CS_fnc_CSS_getBallisticData = {
    params ["_unit", "_weapon", "_muzzle", "_mode", "_magazine"];

    if (_weapon isEqualTo "" || { _magazine isEqualTo "" }) exitWith { [] };

    private _magCfg = configFile >> "CfgMagazines" >> _magazine;
    private _ammo = getText (_magCfg >> "ammo");
    if (_ammo isEqualTo "") exitWith { [] };

    private _ammoCfg = configFile >> "CfgAmmo" >> _ammo;
    private _cfgs = [_weapon, _muzzle, _mode] call PHEN_CS_fnc_CSS_getMuzzleCfg;
    _cfgs params ["_weaponCfg", "_muzzleCfg", "_modeCfg"];

    private _magSpeed = getNumber (_magCfg >> "initSpeed");
    if (_magSpeed <= 0) then { _magSpeed = getNumber (_ammoCfg >> "typicalSpeed"); };

    private _weaponSpeed = getNumber (_muzzleCfg >> "initSpeed");
    if (_weaponSpeed == 0 && { isNumber (_modeCfg >> "initSpeed") }) then {
        _weaponSpeed = getNumber (_modeCfg >> "initSpeed");
    };

    private _speed = _magSpeed;
    if (_weaponSpeed > 0) then { _speed = _weaponSpeed; };
    if (_weaponSpeed < 0) then { _speed = _magSpeed * (abs _weaponSpeed); };

    private _airFriction = getNumber (_ammoCfg >> "airFriction");
    if ((getNumber (_ammoCfg >> "artilleryLock")) == 1) then { _airFriction = 0; };

    private _gravityCoef = 1;
    if (isNumber (_ammoCfg >> "coefGravity")) then { _gravityCoef = getNumber (_ammoCfg >> "coefGravity"); };

    private _timeToLive = 5;
    if (isNumber (_ammoCfg >> "timeToLive")) then { _timeToLive = getNumber (_ammoCfg >> "timeToLive"); };
    if (_timeToLive <= 0) then { _timeToLive = 5; };

    private _simulation = toLower (getText (_ammoCfg >> "simulation"));
    private _isLauncher = [_unit, _weapon, _ammoCfg] call PHEN_CS_fnc_CSS_isLauncherWeapon;
    private _isSupported = ((_simulation find "shotbullet") >= 0) || { (_simulation find "shotshell") >= 0 };

    [_speed, _airFriction, _gravityCoef, _timeToLive, _simulation, _isLauncher, _isSupported, _ammo, _ammoCfg]
};

PHEN_CS_fnc_CSS_isAimHitValid = {
    params ["_startASL", "_hit"];

    if !(_hit isEqualType []) exitWith { false };
    if ((count _hit) < 1) exitWith { false };

    private _hitPosASL = _hit # 0;
    if !(_hitPosASL isEqualType []) exitWith { false };
    if ((count _hitPosASL) < 3) exitWith { false };
    if ((_startASL distance _hitPosASL) < PHEN_CS_CSS_MinAimSolutionDistance) exitWith { false };

    private _hitAGL = ASLToAGL _hitPosASL;
    if ((_hitAGL # 2) < -1) exitWith { false };

    true
};

PHEN_CS_fnc_CSS_getZeroDistance = {
    params ["_zeroing"];

    private _zeroDistance = 100;
    if ((typeName _zeroing) isEqualTo "ARRAY") then {
        if ((count _zeroing) > 0) then { _zeroDistance = _zeroing # 0; };
    } else {
        if ((typeName _zeroing) isEqualTo "SCALAR") then { _zeroDistance = _zeroing; };
    };

    if (_zeroDistance <= 0) then { _zeroDistance = 100; };
    _zeroDistance
};

PHEN_CS_fnc_CSS_applyZeroing = {
    params ["_sightDir", "_speed", "_zeroDistance", "_gravityCoef"];

    private _dir = vectorNormalized _sightDir;
    if ((vectorMagnitude _dir) <= 0.001 || { _speed <= 0 } || { _zeroDistance <= 0 }) exitWith { _dir };

    private _worldUp = [0,0,1];
    private _right = _dir vectorCrossProduct _worldUp;
    if ((vectorMagnitude _right) <= 0.001) then { _right = [1,0,0]; };
    _right = vectorNormalized _right;
    private _pitchUp = vectorNormalized (_right vectorCrossProduct _dir);

    private _timeToZero = _zeroDistance / (_speed max 1);
    private _dropAtZero = 0.5 * 9.81 * _gravityCoef * _timeToZero * _timeToZero;
    private _lift = (_dropAtZero / (_zeroDistance max 1)) min 0.35;

    vectorNormalized (_dir vectorAdd (_pitchUp vectorMultiply _lift))
};

PHEN_CS_fnc_CSS_updateAimPrediction = {
    if !(call PHEN_CS_fnc_CSS_hasSuite) exitWith { PHEN_CS_CSS_AimSolution = []; };

    private _unit = call PHEN_CS_fnc_CSS_getUnit;
    if (isNull _unit || { !alive _unit } || { !(isNull (objectParent _unit)) }) exitWith { PHEN_CS_CSS_AimSolution = []; };

    private _state = weaponState _unit;
    _state params ["_weapon", "_muzzle", "_mode", "_magazine", "_ammoCount"];
    if (_weapon isEqualTo "") then { _weapon = currentWeapon _unit; };
    if (_muzzle isEqualTo "") then { _muzzle = currentMuzzle _unit; };
    if (_magazine isEqualTo "") then { _magazine = currentMagazine _unit; };
    if (_weapon isEqualTo "" || { _ammoCount <= 0 }) exitWith { PHEN_CS_CSS_AimSolution = []; };
    if !(_weapon in [primaryWeapon _unit, handgunWeapon _unit, secondaryWeapon _unit]) exitWith { PHEN_CS_CSS_AimSolution = []; };

    private _zeroing = _unit currentZeroing [_weapon, _muzzle];
    private _zeroDistance = [_zeroing] call PHEN_CS_fnc_CSS_getZeroDistance;
    private _aimRay = [_unit, _weapon] call PHEN_CS_fnc_CSS_getAimRay;
    _aimRay params ["_startASL", "_sightDir", "_weaponDir", "_fromWeapon"];
    if ((vectorMagnitude _sightDir) <= 0.001) exitWith { PHEN_CS_CSS_AimSolution = []; };

    private _endASL = _startASL vectorAdd (_sightDir vectorMultiply 5000);
    private _rayHits = lineIntersectsSurfaces [_startASL, _endASL, _unit, vehicle _unit, true, 1, "FIRE", "GEOM", true];
    private _rayPosASL = if (_rayHits isEqualTo []) then { [] } else { (_rayHits # 0) # 0 };

    private _ballisticData = [_unit, _weapon, _muzzle, _mode, _magazine] call PHEN_CS_fnc_CSS_getBallisticData;
    if (_ballisticData isEqualTo []) exitWith { PHEN_CS_CSS_AimSolution = []; };
    _ballisticData params ["_speed", "_airFriction", "_gravityCoef", "_timeToLive", "_simulation", "_isLauncher", "_isSupported", "_ammo", "_ammoCfg"];

    private _hasACEAdvancedBallistics = isClass (configFile >> "CfgPatches" >> "ace_advanced_ballistics");
    private _label = if (_hasACEAdvancedBallistics) then { "APPROX ACE" } else { "PREDICTED" };

    if (!_isSupported || { _isLauncher }) exitWith {
        private _noSolution = "NO SOLUTION";
        PHEN_CS_CSS_AimSolution = [];
    };

    if (_speed <= 0) exitWith {
        if (_rayHits isEqualTo [] || { !([_startASL, _rayHits # 0] call PHEN_CS_fnc_CSS_isAimHitValid) }) then {
            PHEN_CS_CSS_AimSolution = [];
        } else {
            PHEN_CS_CSS_AimSolution = [_rayPosASL, diag_tickTime + 0.35, "ray", "APPROX", _zeroDistance];
        };
    };

    private _dt = getNumber (_ammoCfg >> "simulationStep");
    if (_dt <= 0) then { _dt = 0.025; };
    _dt = (_dt max 0.01) min 0.05;

    private _dir = if (_fromWeapon) then { _sightDir } else { [_sightDir, _speed, _zeroDistance, _gravityCoef] call PHEN_CS_fnc_CSS_applyZeroing };
    private _pos = _startASL;
    private _vel = _dir vectorMultiply _speed;
    private _hit = [];
    private _maxSteps = (ceil (_timeToLive / _dt)) min 900;

    for "_i" from 0 to _maxSteps do {
        private _speedNow = vectorMagnitude _vel;
        if (_airFriction != 0 && { _speedNow > 0 }) then {
            private _dragAccel = _vel vectorMultiply (_speedNow * _airFriction);
            _vel = _vel vectorAdd (_dragAccel vectorMultiply _dt);
        };

        _vel = _vel vectorAdd [0,0,(-9.81 * _gravityCoef * _dt)];
        private _next = _pos vectorAdd (_vel vectorMultiply _dt);
        private _segHits = lineIntersectsSurfaces [_pos, _next, _unit, vehicle _unit, true, 1, "FIRE", "GEOM", true];
        if !(_segHits isEqualTo []) then {
            private _hitPosASL = (_segHits # 0) # 0;
            if ([_startASL, _segHits # 0] call PHEN_CS_fnc_CSS_isAimHitValid) exitWith { _hit = _segHits # 0; };
        };
        _pos = _next;
        if ((_startASL distance _pos) > 5000) exitWith {};
    };

    if !(_hit isEqualTo []) then {
        PHEN_CS_CSS_AimSolution = [_hit # 0, diag_tickTime + 0.35, "ballistic", _label, _zeroDistance];
    } else {
        if (_rayHits isEqualTo [] || { !([_startASL, _rayHits # 0] call PHEN_CS_fnc_CSS_isAimHitValid) }) then {
            PHEN_CS_CSS_AimSolution = [];
        } else {
            PHEN_CS_CSS_AimSolution = [_rayPosASL, diag_tickTime + 0.35, "ray", "APPROX", _zeroDistance];
        };
    };
};

PHEN_CS_fnc_CSS_applyNativeFocusState = {
    PHEN_CS_CSS_FocusActive = (inputAction "zoomTemp") > 0;
    PHEN_CS_CSS_FocusKeyNames = actionKeysNamesArray "zoomTemp";
    PHEN_CS_CSS_FocusActive
};

PHEN_CS_fnc_CSS_showFocusStatus = {
    if !(call PHEN_CS_fnc_CSS_hasSuite) exitWith { false };

    call PHEN_CS_fnc_CSS_applyNativeFocusState;
    private _keys = PHEN_CS_CSS_FocusKeyNames;
    private _keyText = if (_keys isEqualTo []) then { "Unbound" } else { _keys joinString ", " };
    private _stateText = if (PHEN_CS_CSS_FocusActive) then { "ACTIVE" } else { "READY" };

    hintSilent parseText format [
        "<t color='#66ccff'>ARGUS NATIVE FOCUS</t><br/><t size='1.05'>%1</t><br/><t size='0.85'>Hold: %2</t>",
        _stateText,
        _keyText
    ];

    false
};

PHEN_CS_fnc_CSS_draw3D = {
    if !(call PHEN_CS_fnc_CSS_hasSuite) exitWith {};

    private _unit = call PHEN_CS_fnc_CSS_getUnit;
    private _contacts = PHEN_CS_CSS_FriendContacts select { !(isNull (_x # 0)) && { _unit distance (_x # 0) <= PHEN_CS_CSS_AllyRange } };
    private _allyMarkerScale = ((missionNamespace getVariable ["PHEN_CS_CSS_AllyMarkerScale", 1]) max 0.25) min 2;
    private _mineMarkerScale = ((missionNamespace getVariable ["PHEN_CS_CSS_MineMarkerScale", 1]) max 0.25) min 2;
    private _hudScale = ((missionNamespace getVariable ["PHEN_CS_CSS_HudScale", 1]) max 0.5) min 2;

    {
        _x params ["_contact", "_posASL"];
        private _distance = _unit distance _contact;
        if (_distance <= PHEN_CS_CSS_AllyRange) then {
            if ([_unit, _contact, _posASL, PHEN_CS_CSS_AllyRange] call PHEN_CS_fnc_CSS_isMarkerVisible) then {
                private _classData = [_contact] call PHEN_CS_fnc_CSS_classifyContact;
                _classData params ["_classCode", "_icon", "_color", "_sizeFactor"];
                private _size = (linearConversion [0, PHEN_CS_CSS_AllyRange, _distance, 0.95, 0.23, true]) * _sizeFactor * _allyMarkerScale;
                private _label = [_contact] call PHEN_CS_fnc_CSS_getDisplayName;
                private _text = format ["%1 %2 %3m", _classCode, _label, round _distance];
                drawIcon3D [_icon, _color, ASLToAGL _posASL, _size, _size, 0, _text, 1, 0.028 * _size, "RobotoCondensed", "center", false];
            };
        };
    } forEach _contacts;

    {
        _x params ["_mine", "_minePosASL"];
        if (!isNull _mine && { _unit distance _mine <= PHEN_CS_CSS_MineRadius }) then {
            if ([_unit, _mine, _minePosASL, PHEN_CS_CSS_MineRadius] call PHEN_CS_fnc_CSS_isMarkerVisible) then {
                private _classData = [_mine, true] call PHEN_CS_fnc_CSS_classifyContact;
                _classData params ["_classCode", "_icon", "_color", "_sizeFactor"];
                private _distance = round (_unit distance _mine);
                private _mineSize = 0.75 * _mineMarkerScale;
                drawIcon3D ["\a3\ui_f\data\map\markers\military\warning_ca.paa", _color, ASLToAGL _minePosASL, _mineSize, _mineSize, 0, format ["%1 %2 %3m", _classCode, "MINE", _distance], 1, 0.03 * _mineMarkerScale, "RobotoCondensed", "center", false];
            };
        };
    } forEach (PHEN_CS_CSS_MineContacts select { !(isNull (_x # 0)) && { _unit distance (_x # 0) <= PHEN_CS_CSS_MineRadius } });

    private _solution = PHEN_CS_CSS_AimSolution;
    if !(_solution isEqualTo []) then {
        _solution params ["_impactPosASL", "_expiresAt", "_method", "_label"];
        if (_expiresAt > diag_tickTime && { [_unit, _impactPosASL, 5000] call PHEN_CS_fnc_CSS_isAimVisible }) then {
            private _color = if (_method isEqualTo "ballistic") then { [0.2,0.85,1,0.9] } else { [1,0.72,0.1,0.78] };
            drawIcon3D ["\a3\ui_f\data\map\markers\military\destroy_ca.paa", _color, ASLToAGL _impactPosASL, 0.72 * _hudScale, 0.72 * _hudScale, 0, _label, 1, 0.032 * _hudScale, "RobotoCondensed", "center", false];
        };
    };
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

    if (isNil { missionNamespace getVariable "PHEN_CS_CSS_AimPFH" }) then {
        missionNamespace setVariable ["PHEN_CS_CSS_AimPFH", [{
            call PHEN_CS_fnc_CSS_updateAimPrediction;
        }, 0.15, []] call CBA_fnc_addPerFrameHandler];
    };
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
