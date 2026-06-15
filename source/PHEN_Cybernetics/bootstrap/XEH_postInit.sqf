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
PHEN_CS_CSS_MinTrajectoryCollisionDistance = 25;
PHEN_CS_CSS_MinTrajectoryCollisionTime = 0.08;
PHEN_CS_CSS_ShellMinTrajectoryCollisionDistance = 8;
PHEN_CS_CSS_ShellMinTrajectoryCollisionTime = 0.04;
PHEN_CS_CSS_ImpactMatchTolerance = 75;
PHEN_CS_CSS_MaxRadarContacts = 32;
PHEN_CS_CSS_AimSolution = [];
PHEN_CS_CSS_AimDebugState = ["init", [], 0];
PHEN_CS_CSS_AimDebugLastLog = 0;
PHEN_CS_CSS_PostShotDebugState = ["init", [], 0];
PHEN_CS_CSS_PostShotDebugLastLog = 0;
PHEN_CS_CSS_ShotCalibration = [];
PHEN_CS_CSS_LastProjectileImpactState = ["init", [], 0];
PHEN_CS_CSS_ShotSequence = 0;
PHEN_CS_CSS_LastShotContext = [];
PHEN_CS_CSS_AimCache = [];
PHEN_CS_CSS_CalibrationMinBiasDeg = 0.5;
PHEN_CS_CSS_AimUpdateDefaultInterval = 0.18;
PHEN_CS_CSS_AimUpdateShellInterval = 0.45;
PHEN_CS_CSS_AimUpdateRocketInterval = 0.25;
PHEN_CS_CSS_AimReuseAngleDeg = 0.35;
PHEN_CS_CSS_AimReuseShellAngleDeg = 0.45;
PHEN_CS_CSS_AimSolutionTTL = 0.75;
PHEN_CS_CSS_AimDrawSurfaceLift = 0.35;
if (isNil "PHEN_CS_CSS_UseShotCalibration") then { PHEN_CS_CSS_UseShotCalibration = false; };
PHEN_CS_CSS_BallisticConfigCache = createHashMap;
PHEN_CS_CSS_BallisticAdvancedMode = false;
PHEN_CS_CSS_CoriolisOmega = 0;
PHEN_CS_CSS_FriendContacts = [];
PHEN_CS_CSS_MineContacts = [];
PHEN_CS_CSS_RadarContacts = [];

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
    PHEN_CS_CSS_FriendContacts = [_unit, _contacts, PHEN_CS_CSS_AllyRange] call PHEN_CS_fnc_CSS_filterVisibleContacts;
    PHEN_CS_CSS_MineContacts = [_unit, _mines, PHEN_CS_CSS_MineRadius, true] call PHEN_CS_fnc_CSS_filterVisibleContacts;
    PHEN_CS_CSS_RadarContacts = PHEN_CS_CSS_FriendContacts apply { _x # 0 };

    private _mineCount = count PHEN_CS_CSS_MineContacts;
    private _textCtrl = uiNamespace getVariable ["PHEN_CS_CSS_TextCtrl", controlNull];
    private _scaleIndex = missionNamespace getVariable ["PHEN_CS_CSS_RadarScaleIndex", 2];
    _scaleIndex = (_scaleIndex max 0) min ((count PHEN_CS_CSS_RadarScaleLevels) - 1);
    private _radarRange = PHEN_CS_CSS_RadarScaleLevels # _scaleIndex;
    private _layout = call PHEN_CS_fnc_CSS_getHudLayout;
    _layout params ["_hudScale", "_panelX", "_panelY", "_panelW", "_panelH", "_centerX", "_centerY", "_radius", "_dotBase", "_noseOffset", "_textScale"];

    if (!isNull _textCtrl) then {
        _textCtrl ctrlSetStructuredText parseText format [
            "<t size='%5' color='#66ccff'>ARGUS COMBAT OPTICS</t><br/><t size='%6'>%1</t><br/><t size='%7'>RADAR %2m | ALLIES %3 | MINES %4</t>",
            call PHEN_CS_fnc_CSS_getVitalsText,
            _radarRange,
            count PHEN_CS_CSS_FriendContacts,
            _mineCount,
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

PHEN_CS_fnc_CSS_getProjectileFamily = {
    params [["_simulation", ""], ["_isLauncher", false]];

    private _sim = toLower _simulation;
    if ((_sim find "shotbullet") >= 0) exitWith { "bullet" };
    if ((_sim find "shotshell") >= 0) exitWith { "shell" };
    if ((_sim find "shotrocket") >= 0) exitWith { "rocket" };
    if ((_sim find "shotmissile") >= 0) exitWith { "missile" };
    if ((_sim find "shotgrenade") >= 0) exitWith { "grenade" };
    if (_isLauncher) exitWith { "launcher" };

    "unknown"
};

PHEN_CS_fnc_CSS_getRocketPhase = {
    params [["_elapsed", 0], ["_rocketData", []]];

    _rocketData params [["_initTime", 0], ["_thrustTime", 0], ["_thrust", 0]];
    private _active = (_thrustTime > 0)
        && { _thrust != 0 }
        && { _elapsed >= _initTime }
        && { _elapsed <= (_initTime + _thrustTime) };

    if (_active) exitWith { "active_thrust" };
    "ballistic"
};

PHEN_CS_fnc_CSS_getRocketAccel = {
    params [["_dir", [0,0,0]], ["_vel", [0,0,0]], ["_elapsed", 0], ["_rocketData", []], ["_airFriction", 0]];

    _rocketData params [["_initTime", 0], ["_thrustTime", 0], ["_thrust", 0], ["_maxSpeed", 0], ["_sideAirFriction", 0]];

    private _speedNow = vectorMagnitude _vel;
    private _forward = if (_speedNow > 0.1) then { vectorNormalized _vel } else { vectorNormalized _dir };
    private _accel = [0,0,0];
    private _thrustAccel = [0,0,0];
    private _dragAccel = [0,0,0];
    private _sideAccel = [0,0,0];
    private _phase = [_elapsed, _rocketData] call PHEN_CS_fnc_CSS_getRocketPhase;

    if (_phase isEqualTo "active_thrust") then {
        _thrustAccel = _forward vectorMultiply _thrust;
        _accel = _accel vectorAdd _thrustAccel;
    };

    if (_airFriction != 0 && { _speedNow > 0 }) then {
        _dragAccel = _vel vectorMultiply (_speedNow * _airFriction);
        _accel = _accel vectorAdd _dragAccel;
    };

    if (_sideAirFriction != 0 && { _speedNow > 0 }) then {
        private _forwardComponent = _forward vectorMultiply (_vel vectorDotProduct _forward);
        private _sideVel = _vel vectorAdd (_forwardComponent vectorMultiply -1);
        _sideAccel = _sideVel vectorMultiply ((abs _sideAirFriction) * -1 * _speedNow);
        _accel = _accel vectorAdd _sideAccel;
    };

    [_accel, _maxSpeed, _phase, _thrustAccel, _dragAccel, _sideAccel]
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

PHEN_CS_fnc_CSS_getDiscreteDistance = {
    params ["_muzzleCfg", "_modeCfg"];

    private _distances = [];
    if (isArray (_modeCfg >> "discreteDistance")) then {
        _distances = getArray (_modeCfg >> "discreteDistance");
    };
    if (_distances isEqualTo [] && { isArray (_muzzleCfg >> "discreteDistance") }) then {
        _distances = getArray (_muzzleCfg >> "discreteDistance");
    };

    _distances
};

PHEN_CS_fnc_CSS_getEffectiveInitSpeed = {
    params ["_weaponCfg", "_muzzleCfg", "_modeCfg", "_magCfg", "_ammoCfg"];

    private _magSpeed = getNumber (_magCfg >> "initSpeed");
    if (_magSpeed <= 0) then { _magSpeed = getNumber (_ammoCfg >> "typicalSpeed"); };
    private _simulation = toLower (getText (_ammoCfg >> "simulation"));
    private _isProjectileMagSpeedAuthoritative = _simulation in ["shotrocket", "shotmissile", "shotshell"];

    private _weaponSpeed = 0;
    if (isNumber (_muzzleCfg >> "initSpeed")) then {
        _weaponSpeed = getNumber (_muzzleCfg >> "initSpeed");
    };
    if (_weaponSpeed == 0 && { isNumber (_modeCfg >> "initSpeed") }) then {
        _weaponSpeed = getNumber (_modeCfg >> "initSpeed");
    };

    private _speed = _magSpeed;
    if (_isProjectileMagSpeedAuthoritative && { _magSpeed > 0 } && { _weaponSpeed >= 0 }) exitWith { _magSpeed };
    if (_weaponSpeed > 0) then { _speed = _weaponSpeed; };
    if (_weaponSpeed < 0) then { _speed = _magSpeed * (abs _weaponSpeed); };

    _speed
};

PHEN_CS_fnc_CSS_getSimulationStep = {
    params ["_ammoCfg"];

    private _dt = 0;
    if (isNumber (_ammoCfg >> "simulationStep")) then {
        _dt = getNumber (_ammoCfg >> "simulationStep");
    };
    if (_dt <= 0 && { isNumber (_ammoCfg >> "deltaT") }) then {
        _dt = getNumber (_ammoCfg >> "deltaT");
    };
    if (_dt <= 0) then { _dt = 0.025; };

    (_dt max 0.01) min 0.05
};

PHEN_CS_fnc_CSS_getBallisticCacheKey = {
    params ["_ammo", "_weapon", "_muzzle", "_mode", "_magazine"];

    format ["%1|%2|%3|%4|%5", _ammo, _weapon, _muzzle, _mode, _magazine]
};

PHEN_CS_fnc_CSS_getPredictiveRocketData = {
    params [["_initTime", 0], ["_thrustTime", 0], ["_thrust", 0], ["_maxSpeed", 0], ["_sideAirFriction", 0], ["_projectileFamily", ""]];

    private _family = toLower _projectileFamily;
    private _predictiveInitTime = _initTime;
    private _normalization = "raw_config";

    if (_family in ["rocket", "missile"] && { _initTime > 0 } && { _thrustTime > 0 } && { _thrust != 0 }) then {
        _predictiveInitTime = 0;
        _normalization = "active_from_launch";
    };

    [[_predictiveInitTime, _thrustTime, _thrust, _maxSpeed, _sideAirFriction], _normalization, _predictiveInitTime, _initTime]
};

PHEN_CS_fnc_CSS_getBallisticProfile = {
    params ["_unit", "_weapon", "_muzzle", "_mode", "_magazine"];

    if (_weapon isEqualTo "" || { _magazine isEqualTo "" }) exitWith { [] };

    private _magCfg = configFile >> "CfgMagazines" >> _magazine;
    private _ammo = getText (_magCfg >> "ammo");
    if (_ammo isEqualTo "") exitWith { [] };

    private _cacheKey = [_ammo, _weapon, _muzzle, _mode, _magazine] call PHEN_CS_fnc_CSS_getBallisticCacheKey;
    private _cached = PHEN_CS_CSS_BallisticConfigCache getOrDefault [_cacheKey, []];
    if !(_cached isEqualTo []) exitWith { +_cached };

    private _ammoCfg = configFile >> "CfgAmmo" >> _ammo;
    private _cfgs = [_weapon, _muzzle, _mode] call PHEN_CS_fnc_CSS_getMuzzleCfg;
    _cfgs params ["_weaponCfg", "_muzzleCfg", "_modeCfg"];

    private _speed = [_weaponCfg, _muzzleCfg, _modeCfg, _magCfg, _ammoCfg] call PHEN_CS_fnc_CSS_getEffectiveInitSpeed;
    private _airFriction = getNumber (_ammoCfg >> "airFriction");
    if ((getNumber (_ammoCfg >> "artilleryLock")) == 1) then { _airFriction = 0; };

    private _gravityCoef = 1;
    if (isNumber (_ammoCfg >> "coefGravity")) then { _gravityCoef = getNumber (_ammoCfg >> "coefGravity"); };

    private _timeToLive = 5;
    if (isNumber (_ammoCfg >> "timeToLive")) then { _timeToLive = getNumber (_ammoCfg >> "timeToLive"); };
    if (_timeToLive <= 0) then { _timeToLive = 5; };

    private _simulation = toLower (getText (_ammoCfg >> "simulation"));
    private _isLauncher = [_unit, _weapon, _ammoCfg] call PHEN_CS_fnc_CSS_isLauncherWeapon;
    private _projectileFamily = [_simulation, _isLauncher] call PHEN_CS_fnc_CSS_getProjectileFamily;
    private _isSupported = _projectileFamily in ["bullet", "shell", "rocket", "missile"];

    private _initTime = 0;
    if (isNumber (_ammoCfg >> "initTime")) then { _initTime = getNumber (_ammoCfg >> "initTime"); };
    private _thrustTime = 0;
    if (isNumber (_ammoCfg >> "thrustTime")) then { _thrustTime = getNumber (_ammoCfg >> "thrustTime"); };
    private _thrust = 0;
    if (isNumber (_ammoCfg >> "thrust")) then { _thrust = getNumber (_ammoCfg >> "thrust"); };
    private _maxSpeed = 0;
    if (isNumber (_ammoCfg >> "maxSpeed")) then { _maxSpeed = getNumber (_ammoCfg >> "maxSpeed"); };
    private _sideAirFriction = 0;
    if (isNumber (_ammoCfg >> "sideAirFriction")) then { _sideAirFriction = getNumber (_ammoCfg >> "sideAirFriction"); };
    private _simulationStep = [_ammoCfg] call PHEN_CS_fnc_CSS_getSimulationStep;
    private _discreteDistance = [_muzzleCfg, _modeCfg] call PHEN_CS_fnc_CSS_getDiscreteDistance;

    private _predictionQuality = switch (_projectileFamily) do {
        case "bullet": { "ballistic" };
        case "shell": { "ballistic" };
        case "rocket": { "rocket_approx" };
        case "missile": { "rocket_approx" };
        default { "unsupported" };
    };
    private _rocketPhaseData = [_initTime, _thrustTime, _thrust, _maxSpeed, _sideAirFriction, _projectileFamily] call PHEN_CS_fnc_CSS_getPredictiveRocketData;
    _rocketPhaseData params ["_rocketData", "_rocketPhaseNormalization", "_rocketPredictiveInitTime", "_rocketConfigInitTime"];

    private _profile = [
        ["cacheKey", _cacheKey],
        ["weapon", _weapon],
        ["muzzle", _muzzle],
        ["mode", _mode],
        ["magazine", _magazine],
        ["ammo", _ammo],
        ["ammoCfg", _ammoCfg],
        ["speed", _speed],
        ["airFriction", _airFriction],
        ["gravityCoef", _gravityCoef],
        ["timeToLive", _timeToLive],
        ["simulation", _simulation],
        ["isLauncher", _isLauncher],
        ["isSupported", _isSupported],
        ["projectileFamily", _projectileFamily],
        ["rocketData", _rocketData],
        ["initTime", _initTime],
        ["rocketConfigInitTime", _rocketConfigInitTime],
        ["rocketPredictiveInitTime", _rocketPredictiveInitTime],
        ["rocketPhaseNormalization", _rocketPhaseNormalization],
        ["thrustTime", _thrustTime],
        ["thrust", _thrust],
        ["maxSpeed", _maxSpeed],
        ["sideAirFriction", _sideAirFriction],
        ["simulationStep", _simulationStep],
        ["discreteDistance", _discreteDistance],
        ["predictionQuality", _predictionQuality],
        ["supportedFamilies", ["bullet", "shell", "rocket", "missile"]]
    ];

    PHEN_CS_CSS_BallisticConfigCache set [_cacheKey, +_profile];
    +_profile
};

PHEN_CS_fnc_CSS_getWeaponSlot = {
    params ["_unit", "_weapon"];

    if (_weapon isEqualTo (primaryWeapon _unit)) exitWith { "primary" };
    if (_weapon isEqualTo (handgunWeapon _unit)) exitWith { "handgun" };
    if (_weapon isEqualTo (secondaryWeapon _unit)) exitWith { "secondary" };

    "unknown"
};

PHEN_CS_fnc_CSS_getWeaponItems = {
    params ["_unit", "_weapon"];

    private _slot = [_unit, _weapon] call PHEN_CS_fnc_CSS_getWeaponSlot;
    switch (_slot) do {
        case "primary": { primaryWeaponItems _unit };
        case "handgun": { handgunItems _unit };
        case "secondary": { secondaryWeaponItems _unit };
        default { [] };
    }
};

PHEN_CS_fnc_CSS_getAttachmentCoefs = {
    params ["_unit", "_weapon"];

    private _slot = [_unit, _weapon] call PHEN_CS_fnc_CSS_getWeaponSlot;
    private _items = [_unit, _weapon] call PHEN_CS_fnc_CSS_getWeaponItems;
    private _muzzleAttachment = "";
    if (_items isEqualType [] && { (count _items) > 0 }) then {
        _muzzleAttachment = _items # 0;
    };

    private _initSpeedCoef = 1;
    private _airFrictionCoef = 1;
    private _typicalSpeedCoef = 1;

    if !(_muzzleAttachment isEqualTo "") then {
        private _itemInfo = configFile >> "CfgWeapons" >> _muzzleAttachment >> "ItemInfo";
        private _magazineCoef = _itemInfo >> "MagazineCoef";
        private _ammoCoef = _itemInfo >> "AmmoCoef";

        if (isNumber (_magazineCoef >> "initSpeed")) then {
            _initSpeedCoef = getNumber (_magazineCoef >> "initSpeed");
        };
        if (isNumber (_ammoCoef >> "airFriction")) then {
            _airFrictionCoef = getNumber (_ammoCoef >> "airFriction");
        };
        if (isNumber (_ammoCoef >> "typicalSpeed")) then {
            _typicalSpeedCoef = getNumber (_ammoCoef >> "typicalSpeed");
        };
    };

    if (_initSpeedCoef <= 0) then { _initSpeedCoef = 1; };
    if (_airFrictionCoef <= 0) then { _airFrictionCoef = 1; };
    if (_typicalSpeedCoef <= 0) then { _typicalSpeedCoef = 1; };

    [_slot, _muzzleAttachment, _initSpeedCoef, _airFrictionCoef, _typicalSpeedCoef]
};

PHEN_CS_fnc_CSS_getAimOrigin = {
    params ["_unit", "_dir"];

    private _originASL = eyePos _unit;
    private _originMethod = "eyePos";

    if ((vectorMagnitude _dir) > 0.001) then {
        _originASL = _originASL vectorAdd ((vectorNormalized _dir) vectorMultiply 0.35);
        _originMethod = "eyePosForward";
    };

    [_originASL, _originMethod]
};

PHEN_CS_fnc_CSS_getAimFrame = {
    params ["_unit", "_weapon", "_speed", "_zeroDistance", "_gravityCoef", ["_applyZeroing", true], ["_ballisticProfile", []]];

    private _weaponDir = vectorNormalized (_unit weaponDirection _weapon);
    private _fromWeapon = (vectorMagnitude _weaponDir) > 0.001;
    private _viewDir = [_unit] call PHEN_CS_fnc_CSS_getViewDirection;
    private _dir = if (_fromWeapon) then { _weaponDir } else { _viewDir };
    private _dirMethod = if (_fromWeapon) then { "weaponDirection" } else { "viewDirection" };
    private _zeroingApplied = false;
    private _zeroingTelemetry = [];
    private _originData = [_unit, _dir] call PHEN_CS_fnc_CSS_getAimOrigin;
    _originData params ["_originASL", "_originMethod"];

    if (_applyZeroing && { _speed > 0 } && { _zeroDistance > 0 }) then {
        if (_ballisticProfile isEqualType [] && { !(_ballisticProfile isEqualTo []) }) then {
            private _zeroingSolution = [_unit, _originASL, _dir, _speed, _zeroDistance, _gravityCoef, _ballisticProfile] call PHEN_CS_fnc_CSS_solveZeroedAimFrame;
            _zeroingSolution params ["_zeroedDir", "_zeroingLift", "_zeroingMeta"];
            _dir = _zeroedDir;
            _zeroingTelemetry = _zeroingMeta;
        } else {
            _dir = [_dir, _speed, _zeroDistance, _gravityCoef] call PHEN_CS_fnc_CSS_applyZeroing;
            _zeroingTelemetry = [["method", "fallback_applyZeroing"]];
        };
        _zeroingApplied = true;
    };
    _dir = vectorNormalized _dir;

    _originData = [_unit, _dir] call PHEN_CS_fnc_CSS_getAimOrigin;
    _originData params ["_originASL", "_originMethod"];

    private _viewCoherence = -1;
    if ((vectorMagnitude _weaponDir) > 0.001 && { (vectorMagnitude _viewDir) > 0.001 }) then {
        _viewCoherence = _weaponDir vectorDotProduct _viewDir;
    };

    [_originASL, _dir, _weaponDir, _viewDir, _originMethod, _dirMethod, _fromWeapon, _zeroingApplied, _viewCoherence, _zeroingTelemetry]
};

PHEN_CS_fnc_CSS_getBallisticData = {
    params ["_unit", "_weapon", "_muzzle", "_mode", "_magazine"];

    private _profile = [_unit, _weapon, _muzzle, _mode, _magazine] call PHEN_CS_fnc_CSS_getBallisticProfile;
    if (_profile isEqualTo []) exitWith { [] };

    private _speed = [_profile, "speed", 0] call PHEN_CS_fnc_CSS_getPairValue;
    private _airFriction = [_profile, "airFriction", 0] call PHEN_CS_fnc_CSS_getPairValue;
    private _gravityCoef = [_profile, "gravityCoef", 1] call PHEN_CS_fnc_CSS_getPairValue;
    private _timeToLive = [_profile, "timeToLive", 5] call PHEN_CS_fnc_CSS_getPairValue;
    private _simulation = [_profile, "simulation", ""] call PHEN_CS_fnc_CSS_getPairValue;
    private _isLauncher = [_profile, "isLauncher", false] call PHEN_CS_fnc_CSS_getPairValue;
    private _isSupported = [_profile, "isSupported", false] call PHEN_CS_fnc_CSS_getPairValue;
    private _ammo = [_profile, "ammo", ""] call PHEN_CS_fnc_CSS_getPairValue;
    private _ammoCfg = [_profile, "ammoCfg", configNull] call PHEN_CS_fnc_CSS_getPairValue;
    private _projectileFamily = [_profile, "projectileFamily", "unknown"] call PHEN_CS_fnc_CSS_getPairValue;
    private _rocketData = [_profile, "rocketData", []] call PHEN_CS_fnc_CSS_getPairValue;
    private _predictionQuality = [_profile, "predictionQuality", "unsupported"] call PHEN_CS_fnc_CSS_getPairValue;
    private _simulationStep = [_profile, "simulationStep", 0.025] call PHEN_CS_fnc_CSS_getPairValue;
    private _attachmentCoefs = [_unit, _weapon] call PHEN_CS_fnc_CSS_getAttachmentCoefs;
    _attachmentCoefs params ["_slot", "_muzzleAttachment", "_initSpeedCoef", "_airFrictionCoef", "_typicalSpeedCoef"];

    _speed = _speed * _initSpeedCoef * _typicalSpeedCoef;
    _airFriction = _airFriction * _airFrictionCoef;
    _profile = +_profile;
    _profile = [_profile, "speed", _speed] call PHEN_CS_fnc_CSS_setPairValue;
    _profile = [_profile, "airFriction", _airFriction] call PHEN_CS_fnc_CSS_setPairValue;
    _profile = [_profile, "attachmentCoefs", _attachmentCoefs] call PHEN_CS_fnc_CSS_setPairValue;

    [_speed, _airFriction, _gravityCoef, _timeToLive, _simulation, _isLauncher, _isSupported, _ammo, _ammoCfg, _attachmentCoefs, _projectileFamily, _rocketData, _predictionQuality, _simulationStep, _profile]
};

PHEN_CS_fnc_CSS_getAimHitStatus = {
    params ["_startASL", "_hit"];

    if !(_hit isEqualType []) exitWith { [false, "bad_hit_type"] };
    if ((count _hit) < 1) exitWith { [false, "empty_hit"] };

    private _hitPosASL = _hit # 0;
    if !(_hitPosASL isEqualType []) exitWith { [false, "bad_position_type"] };
    if ((count _hitPosASL) < 3) exitWith { [false, "bad_position_size"] };
    if ((_startASL distance _hitPosASL) < PHEN_CS_CSS_MinAimSolutionDistance) exitWith { [false, "too_close"] };

    private _hitAGL = ASLToAGL _hitPosASL;
    if ((_hitAGL # 2) < -1) exitWith { [false, "below_surface"] };

    [true, "accepted"]
};

PHEN_CS_fnc_CSS_isAimHitValid = {
    params ["_startASL", "_hit"];

    private _status = [_startASL, _hit] call PHEN_CS_fnc_CSS_getAimHitStatus;
    _status # 0
};

PHEN_CS_fnc_CSS_getTrajectoryHitStatus = {
    params ["_startASL", "_hit", ["_elapsed", 0], ["_projectileFamily", ""]];

    private _status = [_startASL, _hit] call PHEN_CS_fnc_CSS_getAimHitStatus;
    if !(_status # 0) exitWith { _status };

    private _hitPosASL = _hit # 0;
    private _hitDistance = _startASL distance _hitPosASL;
    private _family = toLower _projectileFamily;
    private _minDistance = 0;
    private _minTime = 0;

    switch (_family) do {
        case "bullet": {
            _minDistance = PHEN_CS_CSS_MinTrajectoryCollisionDistance;
            _minTime = PHEN_CS_CSS_MinTrajectoryCollisionTime;
        };
        case "shell": {
            _minDistance = PHEN_CS_CSS_ShellMinTrajectoryCollisionDistance;
            _minTime = PHEN_CS_CSS_ShellMinTrajectoryCollisionTime;
        };
    };

    if (_minDistance > 0 && { _hitDistance < _minDistance } && { _elapsed <= _minTime }) exitWith { [false, "early_trajectory_collision"] };

    _status
};

PHEN_CS_fnc_CSS_allowRayFallback = {
    params ["_reason", "_rayStatus"];

    (_reason isEqualTo "zero_speed") && { (_rayStatus # 0) }
};

PHEN_CS_fnc_CSS_getCoriolisAccel = {
    params [["_vel", [0,0,0]]];

    private _advanced = missionNamespace getVariable ["PHEN_CS_CSS_BallisticAdvancedMode", PHEN_CS_CSS_BallisticAdvancedMode];
    if !(_advanced) exitWith { [0,0,0] };

    private _omega = missionNamespace getVariable ["PHEN_CS_CSS_CoriolisOmega", PHEN_CS_CSS_CoriolisOmega];
    if (_omega isEqualType 0) exitWith {
        [2 * _omega * (_vel # 1), -2 * _omega * (_vel # 0), 0]
    };
    if !(_omega isEqualType [] && { (count _omega) >= 3 }) exitWith { [0,0,0] };

    private _cross = [
        ((_omega # 1) * (_vel # 2)) - ((_omega # 2) * (_vel # 1)),
        ((_omega # 2) * (_vel # 0)) - ((_omega # 0) * (_vel # 2)),
        ((_omega # 0) * (_vel # 1)) - ((_omega # 1) * (_vel # 0))
    ];
    _cross vectorMultiply -2
};

PHEN_CS_fnc_CSS_stepProjectileVelocity = {
    params [
        ["_dir", [0,0,0]],
        ["_vel", [0,0,0]],
        ["_elapsed", 0],
        ["_dt", 0.025],
        ["_projectileFamily", "bullet"],
        ["_airFriction", 0],
        ["_gravityCoef", 1],
        ["_rocketData", []]
    ];

    private _nextVel = _vel;
    private _speedNow = vectorMagnitude _nextVel;
    private _maxSpeedLimit = 0;

    switch (_projectileFamily) do {
        case "bullet": {
            if (_airFriction != 0 && { _speedNow > 0 }) then {
                _nextVel = _nextVel vectorAdd ((_nextVel vectorMultiply (_speedNow * _airFriction)) vectorMultiply _dt);
            };
        };
        case "shell": {
            if (_airFriction != 0 && { _speedNow > 0 }) then {
                _nextVel = _nextVel vectorAdd ((_nextVel vectorMultiply (_speedNow * _airFriction)) vectorMultiply _dt);
            };
        };
        case "rocket": {
            private _rocketAccelData = [_dir, _nextVel, _elapsed, _rocketData, _airFriction] call PHEN_CS_fnc_CSS_getRocketAccel;
            _rocketAccelData params ["_rocketAccel", "_rocketMaxSpeed"];
            _nextVel = _nextVel vectorAdd (_rocketAccel vectorMultiply _dt);
            _maxSpeedLimit = _rocketMaxSpeed;
        };
        case "missile": {
            private _rocketAccelData = [_dir, _nextVel, _elapsed, _rocketData, _airFriction] call PHEN_CS_fnc_CSS_getRocketAccel;
            _rocketAccelData params ["_rocketAccel", "_rocketMaxSpeed"];
            _nextVel = _nextVel vectorAdd (_rocketAccel vectorMultiply _dt);
            _maxSpeedLimit = _rocketMaxSpeed;
        };
        default {
            if (_airFriction != 0 && { _speedNow > 0 }) then {
                _nextVel = _nextVel vectorAdd ((_nextVel vectorMultiply (_speedNow * _airFriction)) vectorMultiply _dt);
            };
        };
    };

    private _coriolisAccel = [_nextVel] call PHEN_CS_fnc_CSS_getCoriolisAccel;
    if ((vectorMagnitude _coriolisAccel) > 0) then {
        _nextVel = _nextVel vectorAdd (_coriolisAccel vectorMultiply _dt);
    };
    _nextVel = _nextVel vectorAdd [0,0,(-9.81 * _gravityCoef * _dt)];

    if (_maxSpeedLimit > 0 && { (vectorMagnitude _nextVel) > _maxSpeedLimit }) then {
        _nextVel = (vectorNormalized _nextVel) vectorMultiply _maxSpeedLimit;
    };

    _nextVel
};

PHEN_CS_fnc_CSS_traceBallisticProfile = {
    params ["_unit", "_aimFrame", "_profile", ["_checkCollision", true]];

    if (isNull _unit || { (count _aimFrame) < 2 }) exitWith { [[], "invalid_aim_frame", [], [], 0, 0] };
    _aimFrame params ["_startASL", "_sightDir"];
    if !(_startASL isEqualType [] && { (count _startASL) >= 3 }) exitWith { [[], "invalid_start", [], [], 0, 0] };
    if !(_sightDir isEqualType [] && { (count _sightDir) >= 3 } && { (vectorMagnitude _sightDir) > 0.001 }) exitWith { [[], "invalid_direction", [], [], 0, 0] };

    private _dir = vectorNormalized _sightDir;
    private _pos = _startASL;
    private _speed = [_profile, "speed", 0] call PHEN_CS_fnc_CSS_getPairValue;
    private _airFriction = [_profile, "airFriction", 0] call PHEN_CS_fnc_CSS_getPairValue;
    private _gravityCoef = [_profile, "gravityCoef", 1] call PHEN_CS_fnc_CSS_getPairValue;
    private _timeToLive = [_profile, "timeToLive", 5] call PHEN_CS_fnc_CSS_getPairValue;
    private _projectileFamily = [_profile, "projectileFamily", "bullet"] call PHEN_CS_fnc_CSS_getPairValue;
    private _rocketData = [_profile, "rocketData", []] call PHEN_CS_fnc_CSS_getPairValue;
    private _dt = [_profile, "simulationStep", 0.025] call PHEN_CS_fnc_CSS_getPairValue;
    _dt = (_dt max 0.01) min 0.05;
    private _vel = _dir vectorMultiply _speed;
    private _hit = [];
    private _hitReason = "no_intersection";
    private _maxSteps = (ceil (_timeToLive / _dt)) min 900;
    private _i = 0;
    private _elapsed = 0;
    private _trajectoryIgnoredHitCount = 0;
    private _trajectoryFirstIgnoredHit = [];
    private _trajectoryIgnoredHitReason = "";

    while { _i <= _maxSteps && { _hit isEqualTo [] } && { (_startASL distance _pos) <= 5000 } } do {
        _elapsed = _i * _dt;
        _vel = [_dir, _vel, _elapsed, _dt, _projectileFamily, _airFriction, _gravityCoef, _rocketData] call PHEN_CS_fnc_CSS_stepProjectileVelocity;
        private _next = _pos vectorAdd (_vel vectorMultiply _dt);

        if (_checkCollision) then {
            private _segHits = lineIntersectsSurfaces [_pos, _next, _unit, vehicle _unit, true, 1, "FIRE", "GEOM", true];
            if !(_segHits isEqualTo []) then {
                private _hitStatus = [_startASL, _segHits # 0, _elapsed, _projectileFamily] call PHEN_CS_fnc_CSS_getTrajectoryHitStatus;
                if (_hitStatus # 0) then {
                    _hitReason = _hitStatus # 1;
                    _hit = _segHits # 0;
                } else {
                    _hitReason = _hitStatus # 1;
                    if (_hitReason isEqualTo "early_trajectory_collision") then {
                        _trajectoryIgnoredHitCount = _trajectoryIgnoredHitCount + 1;
                        if (_trajectoryFirstIgnoredHit isEqualTo []) then { _trajectoryFirstIgnoredHit = _segHits # 0; };
                        _trajectoryIgnoredHitReason = _hitReason;
                    };
                    _pos = _next;
                };
            } else {
                _pos = _next;
            };
        } else {
            _pos = _next;
        };
        _i = _i + 1;
    };

    [_hit, _hitReason, _pos, _vel, _i, _elapsed, _trajectoryIgnoredHitCount, _trajectoryFirstIgnoredHit, _trajectoryIgnoredHitReason]
};

PHEN_CS_fnc_CSS_traceLaunchFramePrediction = {
    params ["_unit", "_projectileStartASL", "_projectileVelocity", "_profile"];

    if !(_projectileStartASL isEqualType [] && { (count _projectileStartASL) >= 3 }) exitWith { [] };
    if !(_projectileVelocity isEqualType [] && { (count _projectileVelocity) >= 3 } && { (vectorMagnitude _projectileVelocity) > 0.1 }) exitWith { [] };
    if !(_profile isEqualType [] && { !(_profile isEqualTo []) }) exitWith { [] };

    private _launchDir = vectorNormalized _projectileVelocity;
    private _launchSpeed = vectorMagnitude _projectileVelocity;
    private _launchProfile = +_profile;
    _launchProfile = [_launchProfile, "speed", _launchSpeed] call PHEN_CS_fnc_CSS_setPairValue;

    private _launchAimFrame = [_projectileStartASL, _launchDir, _launchDir, _launchDir, "projectileFrame0", "projectileVelocity", true, false, 1, []];
    private _trace = [_unit, _launchAimFrame, _launchProfile, true] call PHEN_CS_fnc_CSS_traceBallisticProfile;
    _trace params ["_hit", "_hitReason", "_traceEndASL", "_traceEndVelocity", "_traceSteps", "_traceTimeOfFlight", "_trajectoryIgnoredHitCount", "_trajectoryFirstIgnoredHit", "_trajectoryIgnoredHitReason"];
    private _impactASL = if !(_hit isEqualTo []) then { _hit # 0 } else { _traceEndASL };

    [_impactASL, _launchAimFrame, _trace, _launchProfile]
};

PHEN_CS_fnc_CSS_traceAimTrajectory = {
    params ["_unit", "_ammoCfg", "_aimFrame", "_speed", "_airFriction", "_gravityCoef", "_timeToLive", "_projectileFamily", "_rocketData", ["_simulationStep", 0.025]];

    private _profile = [
        ["speed", _speed],
        ["airFriction", _airFriction],
        ["gravityCoef", _gravityCoef],
        ["timeToLive", _timeToLive],
        ["projectileFamily", _projectileFamily],
        ["rocketData", _rocketData],
        ["simulationStep", _simulationStep]
    ];

    [_unit, _aimFrame, _profile, true] call PHEN_CS_fnc_CSS_traceBallisticProfile
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

PHEN_CS_fnc_CSS_calibrationSharesAcrossZeroing = {
    params [["_projectileFamily", ""]];

    switch (toLower _projectileFamily) do {
        case "shell": { false };
        default { true };
    }
};

PHEN_CS_fnc_CSS_getShotCalibrationKey = {
    params ["_weapon", "_muzzle", "_mode", "_magazine", "_ammo", "_zeroDistance", "_stanceName", ["_projectileFamily", ""]];

    private _sharedAcrossZeroing = [_projectileFamily] call PHEN_CS_fnc_CSS_calibrationSharesAcrossZeroing;
    if (_sharedAcrossZeroing) then {
        format ["%1|%2|%3|%4|%5|shared_zeroing|%6", _weapon, _muzzle, _mode, _magazine, _ammo, _stanceName]
    } else {
        format ["%1|%2|%3|%4|%5|shell_zero_distance|%6|%7", _weapon, _muzzle, _mode, _magazine, _ammo, _zeroDistance, _stanceName]
    }
};

PHEN_CS_fnc_CSS_getShotCalibration = {
    params ["_key"];

    private _idx = PHEN_CS_CSS_ShotCalibration findIf { (_x # 0) isEqualTo _key };
    if (_idx < 0) exitWith { [] };
    (PHEN_CS_CSS_ShotCalibration # _idx) # 1
};

PHEN_CS_fnc_CSS_getPairValue = {
    params [["_pairs", []], ["_key", ""], ["_defaultValue", []]];

    if !(_pairs isEqualType []) exitWith { _defaultValue };
    private _idx = _pairs findIf { (_x isEqualType []) && { (count _x) >= 2 } && { (_x # 0) isEqualTo _key } };
    if (_idx < 0) exitWith { _defaultValue };

    (_pairs # _idx) # 1
};

PHEN_CS_fnc_CSS_setPairValue = {
    params [["_pairs", []], ["_key", ""], ["_value", []]];

    if !(_pairs isEqualType []) exitWith { [] };
    private _idx = _pairs findIf { (_x isEqualType []) && { (count _x) >= 2 } && { (_x # 0) isEqualTo _key } };
    if (_idx < 0) then {
        _pairs pushBack [_key, _value];
    } else {
        _pairs set [_idx, [_key, _value]];
    };

    _pairs
};

PHEN_CS_fnc_CSS_getAimSolutionMeta = {
    params [["_solution", []]];

    if !(_solution isEqualType []) exitWith { [] };
    if ((count _solution) <= 5) exitWith { [] };
    private _meta = _solution # 5;
    if !(_meta isEqualType []) exitWith { [] };

    _meta
};

PHEN_CS_fnc_CSS_nextShotId = {
    params [["_unit", objNull], ["_weapon", ""], ["_ammo", ""], ["_shotTickTime", 0], ["_shotFrameNo", 0]];

    PHEN_CS_CSS_ShotSequence = PHEN_CS_CSS_ShotSequence + 1;
    private _unitId = if (isNull _unit) then { "null" } else { getPlayerUID _unit };
    if (_unitId isEqualTo "") then { _unitId = str _unit; };

    format ["%1|%2|%3|%4|%5|%6", _unitId, PHEN_CS_CSS_ShotSequence, _shotTickTime, _shotFrameNo, _weapon, _ammo]
};

PHEN_CS_fnc_CSS_getProjectileEventShotId = {
    params [["_eventData", []]];

    if !(_eventData isEqualType []) exitWith { "" };
    private _idx = _eventData findIf {
        (_x isEqualType objNull) && { !isNull _x } && { !((_x getVariable ["PHEN_CS_CSS_ShotId", ""]) isEqualTo "") }
    };
    if (_idx < 0) exitWith { "" };

    (_eventData # _idx) getVariable ["PHEN_CS_CSS_ShotId", ""]
};

PHEN_CS_fnc_CSS_measureDirectionError = {
    params ["_predictedDir", "_actualDir"];

    if ((vectorMagnitude _predictedDir) <= 0.001 || { (vectorMagnitude _actualDir) <= 0.001 }) exitWith { [-1, 0, 0, 0] };

    private _predicted = vectorNormalized _predictedDir;
    private _actual = vectorNormalized _actualDir;
    private _dot = ((_predicted vectorDotProduct _actual) max -1) min 1;
    private _right = _predicted vectorCrossProduct [0,0,1];
    if ((vectorMagnitude _right) <= 0.001) then { _right = [1,0,0]; };
    _right = vectorNormalized _right;
    private _up = vectorNormalized (_right vectorCrossProduct _predicted);

    [acos _dot, _actual vectorDotProduct _right, _actual vectorDotProduct _up, _dot]
};

PHEN_CS_fnc_CSS_getAimInputDirection = {
    params ["_unit", "_weapon"];

    private _weaponDir = vectorNormalized (_unit weaponDirection _weapon);
    if ((vectorMagnitude _weaponDir) > 0.001) exitWith { _weaponDir };

    [_unit] call PHEN_CS_fnc_CSS_getViewDirection
};

PHEN_CS_fnc_CSS_getAimUpdateInterval = {
    params [["_projectileFamily", ""]];

    switch (toLower _projectileFamily) do {
        case "shell": { missionNamespace getVariable ["PHEN_CS_CSS_AimUpdateShellInterval", PHEN_CS_CSS_AimUpdateShellInterval] };
        case "rocket": { missionNamespace getVariable ["PHEN_CS_CSS_AimUpdateRocketInterval", PHEN_CS_CSS_AimUpdateRocketInterval] };
        case "missile": { missionNamespace getVariable ["PHEN_CS_CSS_AimUpdateRocketInterval", PHEN_CS_CSS_AimUpdateRocketInterval] };
        default { missionNamespace getVariable ["PHEN_CS_CSS_AimUpdateDefaultInterval", PHEN_CS_CSS_AimUpdateDefaultInterval] };
    }
};

PHEN_CS_fnc_CSS_getAimReuseAngleDeg = {
    params [["_projectileFamily", ""]];

    switch (toLower _projectileFamily) do {
        case "shell": { missionNamespace getVariable ["PHEN_CS_CSS_AimReuseShellAngleDeg", PHEN_CS_CSS_AimReuseShellAngleDeg] };
        default { missionNamespace getVariable ["PHEN_CS_CSS_AimReuseAngleDeg", PHEN_CS_CSS_AimReuseAngleDeg] };
    }
};

PHEN_CS_fnc_CSS_getAimCacheKey = {
    params ["_unit", "_weapon", "_muzzle", "_mode", "_magazine", "_ammo", "_zeroDistance", "_projectileFamily", "_speed", "_simulationStep", "_applyZeroing", "_calibrationApplied"];

    private _advancedMode = missionNamespace getVariable ["PHEN_CS_CSS_BallisticAdvancedMode", PHEN_CS_CSS_BallisticAdvancedMode];
    format [
        "%1|%2|%3|%4|%5|%6|%7|%8|%9|%10|%11|%12|%13",
        _weapon,
        _muzzle,
        _mode,
        _magazine,
        _ammo,
        round (_zeroDistance * 10),
        stance _unit,
        toLower _projectileFamily,
        round (_speed * 100),
        round (_simulationStep * 1000),
        _applyZeroing,
        _calibrationApplied,
        _advancedMode
    ]
};

PHEN_CS_fnc_CSS_refreshAimSolutionExpiry = {
    params [["_solution", []], ["_status", ""], ["_angleDeg", -1], ["_nextUpdateAt", -1]];

    if !(_solution isEqualType []) exitWith { [] };
    private _refreshed = +_solution;
    if ((count _refreshed) > 1) then {
        _refreshed set [1, diag_tickTime + PHEN_CS_CSS_AimSolutionTTL];
    };
    if ((count _refreshed) > 5) then {
        private _meta = +(_refreshed # 5);
        _meta = [_meta, "aimCacheStatus", _status] call PHEN_CS_fnc_CSS_setPairValue;
        _meta = [_meta, "aimCacheAngleDeg", _angleDeg] call PHEN_CS_fnc_CSS_setPairValue;
        _meta = [_meta, "aimCacheNextUpdateAt", _nextUpdateAt] call PHEN_CS_fnc_CSS_setPairValue;
        _refreshed set [5, _meta];
    };

    _refreshed
};

PHEN_CS_fnc_CSS_getReusableAimSolution = {
    params ["_cacheKey", "_inputDir", "_projectileFamily"];

    private _cache = PHEN_CS_CSS_AimCache;
    if !(_cache isEqualType [] && { (count _cache) >= 6 }) exitWith { [false, [], "no_cache", -1] };
    _cache params ["_storedKey", "_storedDir", "_storedFamily", "_storedSolution", "_nextUpdateAt", "_storedAt"];

    if !(_storedKey isEqualTo _cacheKey) exitWith { [false, [], "key_changed", -1] };
    if (diag_tickTime >= _nextUpdateAt) exitWith { [false, [], "expired", -1] };

    private _angleData = [_storedDir, _inputDir] call PHEN_CS_fnc_CSS_measureDirectionError;
    private _angleDeg = _angleData # 0;
    if (_angleDeg < 0) exitWith { [false, [], "invalid_direction", _angleDeg] };

    private _maxAngleDeg = [_projectileFamily] call PHEN_CS_fnc_CSS_getAimReuseAngleDeg;
    if (_angleDeg > _maxAngleDeg) exitWith { [false, [], "aim_throttled_moved", _angleDeg] };

    private _solution = [_storedSolution, "reuse", _angleDeg, _nextUpdateAt] call PHEN_CS_fnc_CSS_refreshAimSolutionExpiry;
    [true, _solution, "reuse", _angleDeg]
};

PHEN_CS_fnc_CSS_storeAimSolutionCache = {
    params ["_cacheKey", "_inputDir", "_projectileFamily", "_solution"];

    private _interval = [_projectileFamily] call PHEN_CS_fnc_CSS_getAimUpdateInterval;
    private _nextUpdateAt = diag_tickTime + (_interval max 0.05);
    private _storedSolution = [_solution, "computed", 0, _nextUpdateAt] call PHEN_CS_fnc_CSS_refreshAimSolutionExpiry;
    PHEN_CS_CSS_AimCache = [_cacheKey, _inputDir, _projectileFamily, +_storedSolution, _nextUpdateAt, diag_tickTime];

    _storedSolution
};

PHEN_CS_fnc_CSS_storeShotCalibration = {
    params ["_unit", "_weapon", "_muzzle", "_mode", "_magazine", "_ammo", "_zeroDistance", "_aimFrame", "_projectileStartASL", "_projectileVelocity", ["_baseMode", "zeroed"], ["_projectileFamily", ""]];

    if (isNull _unit || { (count _aimFrame) < 2 }) exitWith { [] };
    if !(_projectileStartASL isEqualType [] && { (count _projectileStartASL) >= 3 }) exitWith { [] };
    if !(_projectileVelocity isEqualType [] && { (count _projectileVelocity) >= 3 } && { (vectorMagnitude _projectileVelocity) > 0.1 }) exitWith { [] };

    private _stanceName = stance _unit;
    private _key = [_weapon, _muzzle, _mode, _magazine, _ammo, _zeroDistance, _stanceName, _projectileFamily] call PHEN_CS_fnc_CSS_getShotCalibrationKey;
    private _sharedAcrossZeroing = [_projectileFamily] call PHEN_CS_fnc_CSS_calibrationSharesAcrossZeroing;
    private _originLocal = _unit worldToModelVisual (ASLToAGL _projectileStartASL);
    private _predictedDir = _aimFrame # 1;
    private _actualDir = vectorNormalized _projectileVelocity;
    private _dirError = [_predictedDir, _actualDir] call PHEN_CS_fnc_CSS_measureDirectionError;
    _dirError params ["_angleDeg", "_lateralBias", "_verticalBias", "_dot"];
    private _biasMagnitude = sqrt ((_lateralBias * _lateralBias) + (_verticalBias * _verticalBias));

    private _value = [_originLocal, _lateralBias, _verticalBias, _angleDeg, _dot, vectorMagnitude _projectileVelocity, diag_tickTime, _key, _baseMode, _zeroDistance, _biasMagnitude, _sharedAcrossZeroing, _projectileFamily];
    private _idx = PHEN_CS_CSS_ShotCalibration findIf { (_x # 0) isEqualTo _key };
    if (_idx >= 0) then {
        PHEN_CS_CSS_ShotCalibration set [_idx, [_key, _value]];
    } else {
        PHEN_CS_CSS_ShotCalibration pushBack [_key, _value];
        if ((count PHEN_CS_CSS_ShotCalibration) > 32) then {
            PHEN_CS_CSS_ShotCalibration deleteAt 0;
        };
    };

    _value
};

PHEN_CS_fnc_CSS_calibrationWantsZeroing = {
    params ["_calibration", "_fallback"];

    if !(_calibration isEqualType []) exitWith { _fallback };
    if ((count _calibration) <= 8) exitWith { _fallback };

    private _baseMode = toLower (_calibration # 8);
    if (_baseMode in ["raw", "unzeroed", "nozero", "none"]) exitWith { false };
    if (_baseMode in ["zeroed", "applyzeroing", "zeroing"]) exitWith { true };

    _fallback
};

PHEN_CS_fnc_CSS_shouldApplyPredictiveCalibration = {
    params [["_calibration", []], ["_projectileFamily", ""]];

    if ((toLower _projectileFamily) in ["rocket", "missile", "shell"]) exitWith { false };
    if !(missionNamespace getVariable ["PHEN_CS_CSS_UseShotCalibration", PHEN_CS_CSS_UseShotCalibration]) exitWith { false };
    if !(_calibration isEqualType []) exitWith { false };
    if ((count _calibration) <= 3) exitWith { false };

    private _angleDeg = _calibration # 3;
    if !(_angleDeg isEqualType 0) exitWith { false };
    private _minBiasDeg = missionNamespace getVariable ["PHEN_CS_CSS_CalibrationMinBiasDeg", PHEN_CS_CSS_CalibrationMinBiasDeg];
    _angleDeg >= _minBiasDeg
};

PHEN_CS_fnc_CSS_applySpeedCalibration = {
    params ["_speed", "_calibration", ["_projectileFamily", ""]];

    if !([_calibration, _projectileFamily] call PHEN_CS_fnc_CSS_shouldApplyPredictiveCalibration) exitWith { _speed };
    if !(_calibration isEqualType []) exitWith { _speed };
    if ((count _calibration) <= 5) exitWith { _speed };

    private _calibratedSpeed = _calibration # 5;
    if !(_calibratedSpeed isEqualType 0) exitWith { _speed };
    if (_calibratedSpeed <= 1) exitWith { _speed };

    _calibratedSpeed
};

PHEN_CS_fnc_CSS_applyAimCalibration = {
    params ["_unit", "_aimFrame", "_calibration", ["_projectileFamily", ""]];

    if !(missionNamespace getVariable ["PHEN_CS_CSS_UseShotCalibration", PHEN_CS_CSS_UseShotCalibration]) exitWith { _aimFrame };
    if !([_calibration, _projectileFamily] call PHEN_CS_fnc_CSS_shouldApplyPredictiveCalibration) exitWith { _aimFrame };
    if ((count _aimFrame) < 9 || { (count _calibration) < 3 }) exitWith { _aimFrame };

    _aimFrame params ["_originASL", "_dir", "_weaponDir", "_viewDir", "_originMethod", "_dirMethod", "_fromWeapon", "_zeroingApplied", "_viewCoherence"];
    private _zeroingTelemetry = if ((count _aimFrame) > 9) then { _aimFrame # 9 } else { [] };
    _calibration params [["_originLocal", []], ["_lateralBias", 0], ["_verticalBias", 0]];

    if (_originLocal isEqualType [] && { (count _originLocal) >= 3 }) then {
        _originASL = AGLToASL (_unit modelToWorldVisual _originLocal);
        _originMethod = format ["%1+firedCal", _originMethod];
    };

    if ((vectorMagnitude _dir) > 0.001 && { (abs _lateralBias) > 0.00001 || { (abs _verticalBias) > 0.00001 } }) then {
        private _baseDir = vectorNormalized _dir;
        private _right = _baseDir vectorCrossProduct [0,0,1];
        if ((vectorMagnitude _right) <= 0.001) then { _right = [1,0,0]; };
        _right = vectorNormalized _right;
        private _up = vectorNormalized (_right vectorCrossProduct _baseDir);
        _dir = vectorNormalized (_baseDir vectorAdd (_right vectorMultiply _lateralBias) vectorAdd (_up vectorMultiply _verticalBias));
        _dirMethod = format ["%1+firedCal", _dirMethod];
    };

    [_originASL, _dir, _weaponDir, _viewDir, _originMethod, _dirMethod, _fromWeapon, _zeroingApplied, _viewCoherence, _zeroingTelemetry]
};

PHEN_CS_fnc_CSS_shouldApplyZeroing = {
    params ["_unit", "_weapon", "_muzzle", "_mode", "_magazine", "_ammo"];

    private _policy = missionNamespace getVariable ["PHEN_CS_CSS_ZeroingPolicy", "apply"];
    if (_policy isEqualType false) exitWith { _policy };
    if !(_policy isEqualType "") exitWith { true };

    private _normalized = toLower _policy;
    !(_normalized in ["none", "never", "off", "disabled"])
};

PHEN_CS_fnc_CSS_shouldApplyPredictiveZeroing = {
    params [["_projectileFamily", ""], ["_fallback", true]];

    _fallback
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

PHEN_CS_fnc_CSS_traceZeroingProbe = {
    params ["_unit", "_startASL", "_baseDir", "_testDir", "_zeroDistance", "_profile"];

    if !(_startASL isEqualType [] && { (count _startASL) >= 3 }) exitWith { [0, 0, [], 0, 0, false] };
    if !(_baseDir isEqualType [] && { (count _baseDir) >= 3 } && { (vectorMagnitude _baseDir) > 0.001 }) exitWith { [0, 0, [], 0, 0, false] };
    if !(_testDir isEqualType [] && { (count _testDir) >= 3 } && { (vectorMagnitude _testDir) > 0.001 }) exitWith { [0, 0, [], 0, 0, false] };
    if (_zeroDistance <= 0) exitWith { [0, 0, [], 0, 0, false] };

    private _dir = vectorNormalized _testDir;
    private _sightDir = vectorNormalized _baseDir;
    private _right = _sightDir vectorCrossProduct [0,0,1];
    if ((vectorMagnitude _right) <= 0.001) then { _right = [1,0,0]; };
    _right = vectorNormalized _right;
    private _up = vectorNormalized (_right vectorCrossProduct _sightDir);

    private _speed = [_profile, "speed", 0] call PHEN_CS_fnc_CSS_getPairValue;
    private _airFriction = [_profile, "airFriction", 0] call PHEN_CS_fnc_CSS_getPairValue;
    private _gravityCoef = [_profile, "gravityCoef", 1] call PHEN_CS_fnc_CSS_getPairValue;
    private _timeToLive = [_profile, "timeToLive", 5] call PHEN_CS_fnc_CSS_getPairValue;
    private _projectileFamily = [_profile, "projectileFamily", "bullet"] call PHEN_CS_fnc_CSS_getPairValue;
    private _rocketData = [_profile, "rocketData", []] call PHEN_CS_fnc_CSS_getPairValue;
    private _dt = [_profile, "simulationStep", 0.025] call PHEN_CS_fnc_CSS_getPairValue;
    _dt = (_dt max 0.01) min 0.05;

    private _pos = _startASL;
    private _vel = _dir vectorMultiply _speed;
    private _maxSteps = (ceil (_timeToLive / _dt)) min 900;
    private _targetASL = _startASL vectorAdd (_sightDir vectorMultiply _zeroDistance);
    private _sampleASL = _pos;
    private _verticalError = 0;
    private _lateralError = 0;
    private _elapsed = 0;
    private _found = false;
    private _i = 0;

    while { _i <= _maxSteps && { !_found } && { (_startASL distance _pos) <= 5000 } } do {
        _elapsed = _i * _dt;
        private _previousPos = _pos;
        private _previousTravel = (_previousPos vectorAdd (_startASL vectorMultiply -1)) vectorDotProduct _sightDir;
        _vel = [_dir, _vel, _elapsed, _dt, _projectileFamily, _airFriction, _gravityCoef, _rocketData] call PHEN_CS_fnc_CSS_stepProjectileVelocity;
        private _next = _pos vectorAdd (_vel vectorMultiply _dt);
        private _travel = (_next vectorAdd (_startASL vectorMultiply -1)) vectorDotProduct _sightDir;

        if (_travel >= _zeroDistance) then {
            private _denom = (_travel - _previousTravel) max 0.001;
            private _alpha = (((_zeroDistance - _previousTravel) / _denom) max 0) min 1;
            _sampleASL = _previousPos vectorAdd ((_next vectorAdd (_previousPos vectorMultiply -1)) vectorMultiply _alpha);
            private _error = _sampleASL vectorAdd (_targetASL vectorMultiply -1);
            _verticalError = _error vectorDotProduct _up;
            _lateralError = _error vectorDotProduct _right;
            _found = true;
        } else {
            _pos = _next;
        };
        _i = _i + 1;
    };

    if (!_found) then {
        private _error = _pos vectorAdd (_targetASL vectorMultiply -1);
        _verticalError = _error vectorDotProduct _up;
        _lateralError = _error vectorDotProduct _right;
        _sampleASL = _pos;
    };

    [_verticalError, _lateralError, _sampleASL, _i, _elapsed, _found]
};

PHEN_CS_fnc_CSS_solveZeroedAimFrame = {
    params ["_unit", "_originASL", "_baseDir", "_speed", "_zeroDistance", "_gravityCoef", "_profile"];

    private _dir = vectorNormalized _baseDir;
    if ((vectorMagnitude _dir) <= 0.001 || { _speed <= 0 } || { _zeroDistance <= 0 } || { _profile isEqualTo [] }) exitWith {
        private _fallback = [_baseDir, _speed, _zeroDistance, _gravityCoef] call PHEN_CS_fnc_CSS_applyZeroing;
        [_fallback, 0, [["method", "fallback_applyZeroing"]]]
    };

    private _right = _dir vectorCrossProduct [0,0,1];
    if ((vectorMagnitude _right) <= 0.001) then { _right = [1,0,0]; };
    _right = vectorNormalized _right;
    private _up = vectorNormalized (_right vectorCrossProduct _dir);
    private _profileLocal = +_profile;
    _profileLocal = [_profileLocal, "speed", _speed] call PHEN_CS_fnc_CSS_setPairValue;
    _profileLocal = [_profileLocal, "gravityCoef", _gravityCoef] call PHEN_CS_fnc_CSS_setPairValue;
    private _projectileFamily = [_profileLocal, "projectileFamily", ""] call PHEN_CS_fnc_CSS_getPairValue;
    private _zeroingSolverTag = if ((toLower _projectileFamily) isEqualTo "shell") then { "shell_zeroing_solver" } else { "trajectory_zeroing_solver" };

    private _makeDir = {
        params ["_base", "_upVector", "_lift"];
        vectorNormalized (_base vectorAdd (_upVector vectorMultiply _lift))
    };
    private _probe = {
        params ["_unitObj", "_origin", "_base", "_upVector", "_distance", "_profileData", "_lift", "_makeDirFn"];
        private _testDir = [_base, _upVector, _lift] call _makeDirFn;
        [_unitObj, _origin, _base, _testDir, _distance, _profileData] call PHEN_CS_fnc_CSS_traceZeroingProbe
    };

    private _low = -0.1;
    private _high = 0.45;
    private _lowProbe = [_unit, _originASL, _dir, _up, _zeroDistance, _profileLocal, _low, _makeDir] call _probe;
    private _highProbe = [_unit, _originASL, _dir, _up, _zeroDistance, _profileLocal, _high, _makeDir] call _probe;
    private _lowErr = _lowProbe # 0;
    private _highErr = _highProbe # 0;
    private _bestLift = _low;
    private _bestProbe = _lowProbe;
    if ((abs _highErr) < (abs _lowErr)) then {
        _bestLift = _high;
        _bestProbe = _highProbe;
    };

    private _iterations = 0;
    if ((_lowErr * _highErr) <= 0) then {
        for "_i" from 0 to 15 do {
            private _mid = (_low + _high) * 0.5;
            private _midProbe = [_unit, _originASL, _dir, _up, _zeroDistance, _profileLocal, _mid, _makeDir] call _probe;
            private _midErr = _midProbe # 0;
            if ((abs _midErr) < (abs (_bestProbe # 0))) then {
                _bestLift = _mid;
                _bestProbe = _midProbe;
            };
            if ((_lowErr * _midErr) <= 0) then {
                _high = _mid;
                _highErr = _midErr;
            } else {
                _low = _mid;
                _lowErr = _midErr;
            };
            _iterations = _i + 1;
        };
    } else {
        for "_i" from 0 to 11 do {
            private _candidate = -0.1 + (_i * (0.55 / 11));
            private _candidateProbe = [_unit, _originASL, _dir, _up, _zeroDistance, _profileLocal, _candidate, _makeDir] call _probe;
            if ((abs (_candidateProbe # 0)) < (abs (_bestProbe # 0))) then {
                _bestLift = _candidate;
                _bestProbe = _candidateProbe;
            };
            _iterations = _i + 1;
        };
    };

    private _zeroedDir = [_dir, _up, _bestLift] call _makeDir;
    private _telemetry = [
        ["method", "iterative"],
        ["zeroingLift", _bestLift],
        ["zeroingAngle", atan _bestLift],
        ["zeroingVerticalError", _bestProbe # 0],
        ["zeroingLateralError", _bestProbe # 1],
        ["zeroingSampleASL", _bestProbe # 2],
        ["zeroingProbeSteps", _bestProbe # 3],
        ["zeroingProbeTime", _bestProbe # 4],
        ["zeroingProbeReachedDistance", _bestProbe # 5],
        ["zeroingIterations", _iterations],
        ["zeroingProjectileFamily", _projectileFamily],
        ["zeroingSolverTag", _zeroingSolverTag]
    ];

    [_zeroedDir, _bestLift, _telemetry]
};

PHEN_CS_fnc_CSS_logAimDebug = {
    params [["_reason", ""], ["_data", []]];

    if !(missionNamespace getVariable ["PHEN_CS_DebugMode", false]) exitWith { false };
    if (diag_tickTime < (PHEN_CS_CSS_AimDebugLastLog + 0.75)) exitWith { false };

    PHEN_CS_CSS_AimDebugLastLog = diag_tickTime;
    diag_log format ["[PHEN_CS][ArgusAim] %1 | %2", _reason, _data];
    [_reason, _data] call PHEN_CS_fnc_CSS_logAimCorrectionDebug;
    false
};

PHEN_CS_fnc_CSS_logAimCorrectionDebug = {
    params [["_reason", ""], ["_data", []]];

    private _correction = [_data, "correction", []] call PHEN_CS_fnc_CSS_getPairValue;
    if !(_correction isEqualType []) exitWith { false };
    if (_correction isEqualTo []) exitWith { false };

    diag_log format ["[PHEN_CS][ArgusAimCorrection] %1 | %2", _reason, [
        ["weapon", [_data, "weapon", ""] call PHEN_CS_fnc_CSS_getPairValue],
        ["mode", [_data, "mode", ""] call PHEN_CS_fnc_CSS_getPairValue],
        ["ammo", [_data, "ammo", ""] call PHEN_CS_fnc_CSS_getPairValue],
        ["zeroDistance", [_data, "zeroDistance", -1] call PHEN_CS_fnc_CSS_getPairValue],
        ["calibrationAvailable", [_correction, "calibrationAvailable", false] call PHEN_CS_fnc_CSS_getPairValue],
        ["calibrationApplied", [_correction, "calibrationApplied", false] call PHEN_CS_fnc_CSS_getPairValue],
        ["calibrationSkippedReason", [_correction, "calibrationSkippedReason", ""] call PHEN_CS_fnc_CSS_getPairValue],
        ["calibrationSourceZeroDistance", [_correction, "calibrationSourceZeroDistance", -1] call PHEN_CS_fnc_CSS_getPairValue],
        ["activeZeroDistance", [_correction, "activeZeroDistance", -1] call PHEN_CS_fnc_CSS_getPairValue],
        ["calibrationSharedAcrossZeroing", [_correction, "calibrationSharedAcrossZeroing", false] call PHEN_CS_fnc_CSS_getPairValue],
        ["calibrationBiasMagnitude", [_correction, "calibrationBiasMagnitude", -1] call PHEN_CS_fnc_CSS_getPairValue],
        ["correctionDeltaASL", [_correction, "correctionDeltaASL", []] call PHEN_CS_fnc_CSS_getPairValue],
        ["correctionDistance", [_correction, "correctionDistance", -1] call PHEN_CS_fnc_CSS_getPairValue],
        ["correctionDirectionError", [_correction, "correctionDirectionError", []] call PHEN_CS_fnc_CSS_getPairValue]
    ]];
    diag_log format ["[PHEN_CS][ArgusAimCorrectionPoints] %1 | %2", _reason, [
        ["weapon", [_data, "weapon", ""] call PHEN_CS_fnc_CSS_getPairValue],
        ["mode", [_data, "mode", ""] call PHEN_CS_fnc_CSS_getPairValue],
        ["ammo", [_data, "ammo", ""] call PHEN_CS_fnc_CSS_getPairValue],
        ["zeroDistance", [_data, "zeroDistance", -1] call PHEN_CS_fnc_CSS_getPairValue],
        ["preCorrectionAimPointASL", [_correction, "preCorrectionAimPointASL", []] call PHEN_CS_fnc_CSS_getPairValue],
        ["postCorrectionAimPointASL", [_correction, "postCorrectionAimPointASL", []] call PHEN_CS_fnc_CSS_getPairValue],
        ["preCorrectionHitReason", [_correction, "preCorrectionHitReason", ""] call PHEN_CS_fnc_CSS_getPairValue],
        ["postCorrectionHitReason", [_correction, "postCorrectionHitReason", ""] call PHEN_CS_fnc_CSS_getPairValue]
    ]];
    false
};

PHEN_CS_fnc_CSS_setAimDebugState = {
    params [["_reason", ""], ["_data", []]];

    PHEN_CS_CSS_AimDebugState = [_reason, _data, diag_tickTime];
    [_reason, _data] call PHEN_CS_fnc_CSS_logAimDebug;
    false
};

PHEN_CS_fnc_CSS_clearAimSolution = {
    params [["_reason", ""], ["_data", []], ["_keepCache", false]];

    PHEN_CS_CSS_AimSolution = [];
    if (!_keepCache) then { PHEN_CS_CSS_AimCache = []; };
    [_reason, _data] call PHEN_CS_fnc_CSS_setAimDebugState;
};

PHEN_CS_fnc_CSS_getAimDebugPayload = {
    params [
        ["_method", ""],
        ["_unit", objNull],
        ["_weapon", ""],
        ["_muzzle", ""],
        ["_mode", ""],
        ["_magazine", ""],
        ["_ammo", ""],
        ["_simulation", ""],
        ["_speed", 0],
        ["_airFriction", 0],
        ["_gravityCoef", 1],
        ["_zeroDistance", 0],
        ["_weaponSlot", ""],
        ["_aimFrame", []],
        ["_attachmentCoefs", []],
        ["_hitReason", ""],
        ["_extra", []],
        ["_predictionQuality", ""],
        ["_correctionTelemetry", []]
    ];

    private _originASL = [];
    private _dir = [];
    private _weaponDir = [];
    private _viewDir = [];
    private _originMethod = "";
    private _dirMethod = "";
    private _fromWeapon = false;
    private _zeroingApplied = false;
    private _viewCoherence = -1;
    private _zeroingTelemetry = [];

    if (_aimFrame isEqualType [] && { (count _aimFrame) >= 9 }) then {
        _aimFrame params ["_originASLValue", "_dirValue", "_weaponDirValue", "_viewDirValue", "_originMethodValue", "_dirMethodValue", "_fromWeaponValue", "_zeroingAppliedValue", "_viewCoherenceValue"];
        _originASL = _originASLValue;
        _dir = _dirValue;
        _weaponDir = _weaponDirValue;
        _viewDir = _viewDirValue;
        _originMethod = _originMethodValue;
        _dirMethod = _dirMethodValue;
        _fromWeapon = _fromWeaponValue;
        _zeroingApplied = _zeroingAppliedValue;
        _viewCoherence = _viewCoherenceValue;
        if ((count _aimFrame) > 9) then {
            _zeroingTelemetry = _aimFrame # 9;
        };
    };

    [
        ["method", _method],
        ["weapon", _weapon],
        ["muzzle", _muzzle],
        ["mode", _mode],
        ["magazine", _magazine],
        ["ammo", _ammo],
        ["simulation", _simulation],
        ["speed", _speed],
        ["airFriction", _airFriction],
        ["gravityCoef", _gravityCoef],
        ["zeroDistance", _zeroDistance],
        ["weaponSlot", _weaponSlot],
        ["originASL", _originASL],
        ["originMethod", _originMethod],
        ["dir", _dir],
        ["dirMethod", _dirMethod],
        ["weaponDir", _weaponDir],
        ["viewDir", _viewDir],
        ["fromWeapon", _fromWeapon],
        ["zeroingApplied", _zeroingApplied],
        ["zeroingTelemetry", _zeroingTelemetry],
        ["viewCoherence", _viewCoherence],
        ["attachmentCoefs", _attachmentCoefs],
        ["predictionQuality", _predictionQuality],
        ["hitReason", _hitReason],
        ["correction", _correctionTelemetry],
        ["extra", _extra]
    ]
};

PHEN_CS_fnc_CSS_getImpactEventPosition = {
    params [["_impactState", []]];

    if !(_impactState isEqualType []) exitWith { [] };
    if ((count _impactState) < 2) exitWith { [] };

    private _impactKind = _impactState # 0;
    private _eventData = _impactState # 1;
    if !(_eventData isEqualType []) exitWith { [] };

    switch (_impactKind) do {
        case "HitPart": {
            if ((count _eventData) > 3 && { (_eventData # 3) isEqualType [] } && { (count (_eventData # 3)) >= 3 }) exitWith { _eventData # 3 };
            []
        };
        case "HitExplosion": {
            if ((count _eventData) <= 3) exitWith { [] };
            private _hitParts = _eventData # 3;
            if !(_hitParts isEqualType []) exitWith { [] };
            if ((count _hitParts) <= 0) exitWith { [] };
            private _firstHit = _hitParts # 0;
            if !(_firstHit isEqualType []) exitWith { [] };
            if ((count _firstHit) <= 0 || { !((_firstHit # 0) isEqualType []) } || { (count (_firstHit # 0)) < 3 }) exitWith { [] };
            _firstHit # 0
        };
        case "Explode": {
            if ((count _eventData) > 0 && { (_eventData # 0) isEqualType [] } && { (count (_eventData # 0)) >= 3 }) exitWith { _eventData # 0 };
            if ((count _eventData) > 1 && { (_eventData # 1) isEqualType [] } && { (count (_eventData # 1)) >= 3 }) exitWith { _eventData # 1 };
            []
        };
        default {
            []
        };
    }
};

PHEN_CS_fnc_CSS_getImpactEvaluation = {
    params [["_impactState", []], ["_prediction", []], ["_lastASL", []]];

    private _impactKind = "";
    if (_impactState isEqualType [] && { (count _impactState) > 0 }) then {
        _impactKind = _impactState # 0;
    };

    private _hasPrediction = (_prediction isEqualType []) && { (count _prediction) > 0 };
    private _usable = false;
    private _scoreable = false;
    private _reason = "no_impact_event";

    switch (_impactKind) do {
        case "HitPart": {
            _usable = true;
            _scoreable = true;
            _reason = "hitpart";
        };
        case "HitExplosion": {
            _usable = true;
            _scoreable = true;
            _reason = "hitexplosion";
        };
        case "Explode": {
            _usable = true;
            _scoreable = true;
            _reason = "explode";
        };
        case "Deflected": {
            _reason = "excluded_deflected";
        };
        case "Penetrated": {
            _reason = "excluded_penetrated";
        };
        case "fired": {
            _reason = "no_impact_event";
        };
        default {
            if !(_impactKind isEqualTo "") then {
                _reason = format ["unsupported_impact_%1", _impactKind];
            };
        };
    };

    if !(_hasPrediction) then {
        _usable = false;
        _scoreable = false;
        _reason = format ["%1_no_prediction", _reason];
    } else {
        private _impactPosASL = [_impactState] call PHEN_CS_fnc_CSS_getImpactEventPosition;
        if (_scoreable) then {
            if !(_impactPosASL isEqualType [] && { (count _impactPosASL) >= 3 }) then {
                if !(_lastASL isEqualType [] && { (count _lastASL) >= 3 }) then {
                    _usable = false;
                    _scoreable = false;
                    _reason = "impact_position_unavailable";
                } else {
                    _reason = format ["%1_last_position", _reason];
                };
            } else {
                if !(_lastASL isEqualType [] && { (count _lastASL) >= 3 }) then {
                    _usable = false;
                    _scoreable = false;
                    _reason = "trace_end_unavailable";
                } else {
                    private _impactDistance = _impactPosASL distance _lastASL;
                    if (_impactDistance > PHEN_CS_CSS_ImpactMatchTolerance) then {
                        _usable = false;
                        _scoreable = false;
                        _reason = "impact_state_mismatch";
                    };
                };
            };
        };
    };

    [
        ["impactKind", _impactKind],
        ["scoreable", _scoreable],
        ["usable", _usable],
        ["reason", _reason]
    ]
};

PHEN_CS_fnc_CSS_shouldReportPredictionError = {
    params [["_impactEvaluation", []]];

    private _scoreableIdx = _impactEvaluation findIf { (_x isEqualType []) && { (count _x) >= 2 } && { (_x # 0) isEqualTo "scoreable" } };
    private _usableIdx = _impactEvaluation findIf { (_x isEqualType []) && { (count _x) >= 2 } && { (_x # 0) isEqualTo "usable" } };
    if (_scoreableIdx < 0 || { _usableIdx < 0 }) exitWith { false };

    ((_impactEvaluation # _scoreableIdx) # 1) && { ((_impactEvaluation # _usableIdx) # 1) }
};

PHEN_CS_fnc_CSS_logShotPrediction = {
    params [["_reason", ""], ["_data", []]];

    if !(missionNamespace getVariable ["PHEN_CS_DebugMode", false]) exitWith { false };
    diag_log format ["[PHEN_CS][ArgusShotPrediction] %1 | %2", _reason, _data];
    false
};

PHEN_CS_fnc_CSS_logShotTraceFrame = {
    params [["_reason", ""], ["_data", []]];

    if !(missionNamespace getVariable ["PHEN_CS_DebugMode", false]) exitWith { false };
    diag_log format ["[PHEN_CS][ArgusShotTrace] %1 | %2", _reason, _data];
    false
};

PHEN_CS_fnc_CSS_logShotImpact = {
    params [["_reason", ""], ["_data", []]];

    if !(missionNamespace getVariable ["PHEN_CS_DebugMode", false]) exitWith { false };
    diag_log format ["[PHEN_CS][ArgusShotImpact] %1 | %2", _reason, _data];
    false
};

PHEN_CS_fnc_CSS_logShotContext = {
    params [["_reason", ""], ["_data", []]];

    if !(missionNamespace getVariable ["PHEN_CS_DebugMode", false]) exitWith { false };
    diag_log format ["[PHEN_CS][ArgusShotContext] %1 | %2", _reason, _data];
    false
};

PHEN_CS_fnc_CSS_logShotAim = {
    params [["_reason", ""], ["_data", []]];

    if !(missionNamespace getVariable ["PHEN_CS_DebugMode", false]) exitWith { false };
    diag_log format ["[PHEN_CS][ArgusAim] %1 | %2", _reason, _data];
    [_reason, _data] call PHEN_CS_fnc_CSS_logAimCorrectionDebug;
    false
};

PHEN_CS_fnc_CSS_logPostShotImpactDebug = {
    params [["_reason", ""], ["_data", []]];

    private _shotId = [_data, "shotId", ""] call PHEN_CS_fnc_CSS_getPairValue;
    private _preShotCorrection = [_data, "preShotCorrection", []] call PHEN_CS_fnc_CSS_getPairValue;
    private _prediction = [_data, "prediction", []] call PHEN_CS_fnc_CSS_getPairValue;
    private _predictionZeroDistance = -1;
    if (_prediction isEqualType [] && { (count _prediction) > 4 }) then {
        _predictionZeroDistance = _prediction # 4;
    };
    private _zeroDistance = [_data, "zeroDistance", _predictionZeroDistance] call PHEN_CS_fnc_CSS_getPairValue;
    private _impactEvaluation = [_data, "impactEvaluation", []] call PHEN_CS_fnc_CSS_getPairValue;
    private _impactState = [_data, "impactState", []] call PHEN_CS_fnc_CSS_getPairValue;
    private _impactStateShotId = if (_impactState isEqualType [] && { (count _impactState) > 3 }) then { _impactState # 3 } else { "" };

    diag_log format ["[PHEN_CS][ArgusShotCorrection] %1 | %2", _reason, [
        ["shotId", _shotId],
        ["weapon", [_data, "weapon", ""] call PHEN_CS_fnc_CSS_getPairValue],
        ["mode", [_data, "mode", ""] call PHEN_CS_fnc_CSS_getPairValue],
        ["ammo", [_data, "ammo", ""] call PHEN_CS_fnc_CSS_getPairValue],
        ["zeroDistance", _zeroDistance],
        ["calibrationAvailable", [_preShotCorrection, "calibrationAvailable", false] call PHEN_CS_fnc_CSS_getPairValue],
        ["calibrationApplied", [_preShotCorrection, "calibrationApplied", false] call PHEN_CS_fnc_CSS_getPairValue],
        ["calibrationSkippedReason", [_preShotCorrection, "calibrationSkippedReason", ""] call PHEN_CS_fnc_CSS_getPairValue],
        ["calibrationSourceZeroDistance", [_preShotCorrection, "calibrationSourceZeroDistance", -1] call PHEN_CS_fnc_CSS_getPairValue],
        ["activeZeroDistance", [_preShotCorrection, "activeZeroDistance", _zeroDistance] call PHEN_CS_fnc_CSS_getPairValue],
        ["calibrationSharedAcrossZeroing", [_preShotCorrection, "calibrationSharedAcrossZeroing", false] call PHEN_CS_fnc_CSS_getPairValue],
        ["preShotCorrectionDistance", [_data, "preShotCorrectionDistance", [_preShotCorrection, "correctionDistance", -1] call PHEN_CS_fnc_CSS_getPairValue] call PHEN_CS_fnc_CSS_getPairValue],
        ["preShotCorrectionDeltaASL", [_data, "preShotCorrectionDeltaASL", [_preShotCorrection, "correctionDeltaASL", []] call PHEN_CS_fnc_CSS_getPairValue] call PHEN_CS_fnc_CSS_getPairValue],
        ["correctionDistance", [_preShotCorrection, "correctionDistance", -1] call PHEN_CS_fnc_CSS_getPairValue],
        ["correctionDeltaASL", [_preShotCorrection, "correctionDeltaASL", []] call PHEN_CS_fnc_CSS_getPairValue]
    ]];
    diag_log format ["[PHEN_CS][ArgusShotCorrectionPoints] %1 | %2", _reason, [
        ["shotId", _shotId],
        ["weapon", [_data, "weapon", ""] call PHEN_CS_fnc_CSS_getPairValue],
        ["mode", [_data, "mode", ""] call PHEN_CS_fnc_CSS_getPairValue],
        ["ammo", [_data, "ammo", ""] call PHEN_CS_fnc_CSS_getPairValue],
        ["zeroDistance", _zeroDistance],
        ["preShotUncorrectedAimPointASL", [_data, "preShotUncorrectedAimPointASL", []] call PHEN_CS_fnc_CSS_getPairValue],
        ["preShotCorrectedAimPointASL", [_data, "preShotCorrectedAimPointASL", []] call PHEN_CS_fnc_CSS_getPairValue],
        ["preCorrectionAimPointASL", [_preShotCorrection, "preCorrectionAimPointASL", []] call PHEN_CS_fnc_CSS_getPairValue],
        ["postCorrectionAimPointASL", [_preShotCorrection, "postCorrectionAimPointASL", []] call PHEN_CS_fnc_CSS_getPairValue]
    ]];

    [_reason, [
        ["shotId", _shotId],
        ["weapon", [_data, "weapon", ""] call PHEN_CS_fnc_CSS_getPairValue],
        ["mode", [_data, "mode", ""] call PHEN_CS_fnc_CSS_getPairValue],
        ["ammo", [_data, "ammo", ""] call PHEN_CS_fnc_CSS_getPairValue],
        ["zeroDistance", _zeroDistance],
        ["preShotCorrectedAimPointASL", [_data, "preShotCorrectedAimPointASL", []] call PHEN_CS_fnc_CSS_getPairValue],
        ["postShotImpactPointASL", [_data, "postShotImpactPointASL", []] call PHEN_CS_fnc_CSS_getPairValue],
        ["impactVsCorrectedError", [_data, "impactVsCorrectedError", -1] call PHEN_CS_fnc_CSS_getPairValue],
        ["impactVsCorrectedVectorASL", [_data, "impactVsCorrectedVectorASL", []] call PHEN_CS_fnc_CSS_getPairValue],
        ["predictionErrorUsable", [_data, "predictionErrorUsable", false] call PHEN_CS_fnc_CSS_getPairValue],
        ["impactKind", [_impactEvaluation, "impactKind", ""] call PHEN_CS_fnc_CSS_getPairValue],
        ["impactReason", [_impactEvaluation, "reason", ""] call PHEN_CS_fnc_CSS_getPairValue],
        ["impactScoreable", [_impactEvaluation, "scoreable", false] call PHEN_CS_fnc_CSS_getPairValue],
        ["impactUsable", [_impactEvaluation, "usable", false] call PHEN_CS_fnc_CSS_getPairValue],
        ["impactSelectionMethod", [_data, "impactSelectionMethod", [_preShotCorrection, "impactSelectionMethod", ""] call PHEN_CS_fnc_CSS_getPairValue] call PHEN_CS_fnc_CSS_getPairValue],
        ["impactDistanceFromTraceEnd", [_data, "impactDistanceFromTraceEnd", -1] call PHEN_CS_fnc_CSS_getPairValue],
        ["impactStateShotId", _impactStateShotId],
        ["impactStateShotIdMatch", (_impactStateShotId isEqualTo "") || { _impactStateShotId isEqualTo _shotId }]
    ]] call PHEN_CS_fnc_CSS_logShotImpact;
    false
};

PHEN_CS_fnc_CSS_logPostShotDebug = {
    params [["_reason", ""], ["_data", []]];

    if !(missionNamespace getVariable ["PHEN_CS_DebugMode", false]) exitWith { false };
    if (diag_tickTime < (PHEN_CS_CSS_PostShotDebugLastLog + 0.75)) exitWith { false };

    PHEN_CS_CSS_PostShotDebugLastLog = diag_tickTime;
    diag_log format ["[PHEN_CS][ArgusShot] %1 | %2", _reason, _data];
    [_reason, _data] call PHEN_CS_fnc_CSS_logPostShotImpactDebug;
    false
};

PHEN_CS_fnc_CSS_setPostShotDebugState = {
    params [["_reason", ""], ["_data", []]];

    PHEN_CS_CSS_PostShotDebugState = [_reason, _data, diag_tickTime];
    [_reason, _data] call PHEN_CS_fnc_CSS_logPostShotDebug;
    false
};

PHEN_CS_fnc_CSS_onFiredDebug = {
    params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile"];

    if !(missionNamespace getVariable ["PHEN_CS_DebugMode", false]) exitWith { false };
    if !(_unit isEqualTo (call PHEN_CS_fnc_CSS_getUnit)) exitWith { false };

    private _shotTickTime = diag_tickTime;
    private _shotFrameNo = diag_frameNo;
    private _shotId = [_unit, _weapon, _ammo, _shotTickTime, _shotFrameNo] call PHEN_CS_fnc_CSS_nextShotId;
    private _unitPosASL = getPosASL _unit;
    private _eyePosASL = eyePos _unit;
    private _eyeDirection = eyeDirection _unit;
    private _weaponDirection = _unit weaponDirection _weapon;
    private _prediction = +PHEN_CS_CSS_AimSolution;
    private _predictionMeta = [_prediction] call PHEN_CS_fnc_CSS_getAimSolutionMeta;
    private _preShotCorrectedAimPointASL = if (_prediction isEqualType [] && { (count _prediction) > 0 }) then { _prediction # 0 } else { [] };
    private _preShotUncorrectedAimPointASL = [_predictionMeta, "preCorrectionAimPointASL", []] call PHEN_CS_fnc_CSS_getPairValue;
    private _preCorrectionAimFrame = [_predictionMeta, "preCorrectionAimFrame", []] call PHEN_CS_fnc_CSS_getPairValue;
    private _correctedAimFrame = [_predictionMeta, "postCorrectionAimFrame", []] call PHEN_CS_fnc_CSS_getPairValue;
    private _preShotCorrectionDistance = [_predictionMeta, "correctionDistance", -1] call PHEN_CS_fnc_CSS_getPairValue;
    private _preShotCorrectionDeltaASL = [_predictionMeta, "correctionDeltaASL", []] call PHEN_CS_fnc_CSS_getPairValue;
    private _projectileStartASL = if (isNull _projectile) then { [] } else { getPosASL _projectile };
    private _projectileVelocity = if (isNull _projectile) then { [] } else { velocity _projectile };
    private _shotInfo = if (isNull _projectile) then { [] } else { getShotInfo _projectile };
    private _zeroing = _unit currentZeroing [_weapon, _muzzle];
    private _zeroDistance = [_zeroing] call PHEN_CS_fnc_CSS_getZeroDistance;
    private _ballisticData = [_unit, _weapon, _muzzle, _mode, _magazine] call PHEN_CS_fnc_CSS_getBallisticData;
    private _rawAimFrame = [];
    private _zeroedAimFrame = [];
    private _calibration = [];
    private _rawDirectionError = [-1, 0, 0, 0];
    private _zeroedDirectionError = [-1, 0, 0, 0];
    private _projectileFamily = "";
    private _rocketData = [];
    private _predictionQuality = "";
    private _simulationStep = 0.025;
    private _ballisticProfile = [];
    private _launchFramePredictionApplied = false;
    private _launchFramePredictionReason = "";
    private _launchFrameAimFrame = [];
    private _launchFrameTraceEndASL = [];
    private _launchFrameTraceEndVelocity = [];
    private _launchFrameTraceSteps = -1;
    private _launchFrameTraceTimeOfFlight = -1;
    private _launchFrameIgnoredHitCount = 0;
    private _launchFrameFirstIgnoredHit = [];
    private _launchFrameIgnoredHitReason = "";

    if !(_ballisticData isEqualTo []) then {
        _ballisticData params ["_speed", "_airFriction", "_gravityCoef", "_timeToLive", "_simulation", "_isLauncher", "_isSupported", "_dataAmmo", "_ammoCfg", "_attachmentCoefs", "_projectileFamilyValue", "_rocketDataValue", "_predictionQualityValue"];
        _projectileFamily = _projectileFamilyValue;
        _rocketData = _rocketDataValue;
        _predictionQuality = _predictionQualityValue;
        _simulationStep = if ((count _ballisticData) > 13) then { _ballisticData # 13 } else { 0.025 };
        _ballisticProfile = if ((count _ballisticData) > 14) then { +(_ballisticData # 14) } else { [] };
        _rawAimFrame = [_unit, _weapon, _speed, _zeroDistance, _gravityCoef, false, _ballisticProfile] call PHEN_CS_fnc_CSS_getAimFrame;
        _zeroedAimFrame = [_unit, _weapon, _speed, _zeroDistance, _gravityCoef, true, _ballisticProfile] call PHEN_CS_fnc_CSS_getAimFrame;

        if (_projectileVelocity isEqualType [] && { (count _projectileVelocity) >= 3 } && { (vectorMagnitude _projectileVelocity) > 0.1 }) then {
            if ((count _rawAimFrame) >= 2) then {
                _rawDirectionError = [_rawAimFrame # 1, vectorNormalized _projectileVelocity] call PHEN_CS_fnc_CSS_measureDirectionError;
            };
            if ((count _zeroedAimFrame) >= 2) then {
                _zeroedDirectionError = [_zeroedAimFrame # 1, vectorNormalized _projectileVelocity] call PHEN_CS_fnc_CSS_measureDirectionError;

                private _chosenAimFrame = _zeroedAimFrame;
                private _chosenBaseMode = "zeroed";
                private _rawAngle = _rawDirectionError # 0;
                private _zeroedAngle = _zeroedDirectionError # 0;
                if (_rawAngle >= 0 && { _zeroedAngle < 0 || { _rawAngle <= _zeroedAngle } }) then {
                    _chosenAimFrame = _rawAimFrame;
                    _chosenBaseMode = "raw";
                };

                _calibration = [_unit, _weapon, _muzzle, _mode, _magazine, _ammo, _zeroDistance, _chosenAimFrame, _projectileStartASL, _projectileVelocity, _chosenBaseMode, _projectileFamily] call PHEN_CS_fnc_CSS_storeShotCalibration;
            };
        };

        if (_projectileFamily isEqualTo "shell" && { _projectileStartASL isEqualType [] } && { (count _projectileStartASL) >= 3 } && { _projectileVelocity isEqualType [] } && { (count _projectileVelocity) >= 3 } && { (vectorMagnitude _projectileVelocity) > 0.1 }) then {
            private _launchPredictionData = [_unit, _projectileStartASL, _projectileVelocity, _ballisticProfile] call PHEN_CS_fnc_CSS_traceLaunchFramePrediction;
            if !(_launchPredictionData isEqualTo []) then {
                _launchPredictionData params ["_launchImpactASL", "_launchAimFrameValue", "_launchTrace", "_launchProfile"];
                if (_launchImpactASL isEqualType [] && { (count _launchImpactASL) >= 3 }) then {
                    _launchTrace params ["_launchHit", "_launchHitReason", "_launchTraceEndASLValue", "_launchTraceEndVelocityValue", "_launchTraceStepsValue", "_launchTraceTimeOfFlightValue", "_launchIgnoredHitCountValue", "_launchFirstIgnoredHitValue", "_launchIgnoredHitReasonValue"];
                    _launchFramePredictionApplied = true;
                    _launchFramePredictionReason = "shell_real_projectile_frame";
                    _launchFrameAimFrame = _launchAimFrameValue;
                    _launchFrameTraceEndASL = _launchTraceEndASLValue;
                    _launchFrameTraceEndVelocity = _launchTraceEndVelocityValue;
                    _launchFrameTraceSteps = _launchTraceStepsValue;
                    _launchFrameTraceTimeOfFlight = _launchTraceTimeOfFlightValue;
                    _launchFrameIgnoredHitCount = _launchIgnoredHitCountValue;
                    _launchFrameFirstIgnoredHit = _launchFirstIgnoredHitValue;
                    _launchFrameIgnoredHitReason = _launchIgnoredHitReasonValue;

                    _predictionMeta = +_predictionMeta;
                    _predictionMeta = [_predictionMeta, "preCorrectionAimFrame", _launchAimFrameValue] call PHEN_CS_fnc_CSS_setPairValue;
                    _predictionMeta = [_predictionMeta, "postCorrectionAimFrame", _launchAimFrameValue] call PHEN_CS_fnc_CSS_setPairValue;
                    _predictionMeta = [_predictionMeta, "preCorrectionAimPointASL", _launchImpactASL] call PHEN_CS_fnc_CSS_setPairValue;
                    _predictionMeta = [_predictionMeta, "postCorrectionAimPointASL", _launchImpactASL] call PHEN_CS_fnc_CSS_setPairValue;
                    _predictionMeta = [_predictionMeta, "preCorrectionHitReason", _launchHitReason] call PHEN_CS_fnc_CSS_setPairValue;
                    _predictionMeta = [_predictionMeta, "postCorrectionHitReason", _launchHitReason] call PHEN_CS_fnc_CSS_setPairValue;
                    _predictionMeta = [_predictionMeta, "impactSelectionMethod", "shell_trajectory_collision"] call PHEN_CS_fnc_CSS_setPairValue;
                    _predictionMeta = [_predictionMeta, "traceEndASL", _launchFrameTraceEndASL] call PHEN_CS_fnc_CSS_setPairValue;
                    _predictionMeta = [_predictionMeta, "traceEndVelocity", _launchFrameTraceEndVelocity] call PHEN_CS_fnc_CSS_setPairValue;
                    _predictionMeta = [_predictionMeta, "traceSteps", _launchFrameTraceSteps] call PHEN_CS_fnc_CSS_setPairValue;
                    _predictionMeta = [_predictionMeta, "traceTimeOfFlight", _launchFrameTraceTimeOfFlight] call PHEN_CS_fnc_CSS_setPairValue;
                    _predictionMeta = [_predictionMeta, "trajectoryIgnoredHitCount", _launchFrameIgnoredHitCount] call PHEN_CS_fnc_CSS_setPairValue;
                    _predictionMeta = [_predictionMeta, "trajectoryFirstIgnoredHit", _launchFrameFirstIgnoredHit] call PHEN_CS_fnc_CSS_setPairValue;
                    _predictionMeta = [_predictionMeta, "trajectoryIgnoredHitReason", _launchFrameIgnoredHitReason] call PHEN_CS_fnc_CSS_setPairValue;
                    _predictionMeta = [_predictionMeta, "launchFramePredictionApplied", true] call PHEN_CS_fnc_CSS_setPairValue;
                    _predictionMeta = [_predictionMeta, "launchFramePredictionReason", _launchFramePredictionReason] call PHEN_CS_fnc_CSS_setPairValue;
                    _predictionMeta = [_predictionMeta, "launchFrameAimFrame", _launchFrameAimFrame] call PHEN_CS_fnc_CSS_setPairValue;
                    _prediction = [_launchImpactASL, diag_tickTime + 0.35, "shell_launch_frame", "PREDICTED", _zeroDistance, _predictionMeta];

                    _preShotCorrectedAimPointASL = _launchImpactASL;
                    _preShotUncorrectedAimPointASL = _launchImpactASL;
                    _preCorrectionAimFrame = _launchAimFrame;
                    _correctedAimFrame = _launchAimFrame;
                    _preShotCorrectionDistance = 0;
                    _preShotCorrectionDeltaASL = [0,0,0];
                };
            };
        };
    };

    private _rawAimDirection = if ((count _rawAimFrame) > 1) then { _rawAimFrame # 1 } else { [] };
    private _zeroedAimDirection = if ((count _zeroedAimFrame) > 1) then { _zeroedAimFrame # 1 } else { [] };
    private _correctedAimDirection = if ((count _correctedAimFrame) > 1) then { _correctedAimFrame # 1 } else { [] };
    private _lineTraceHitASL = [_predictionMeta, "lineTraceHitASL", []] call PHEN_CS_fnc_CSS_getPairValue;
    private _lineTraceStatus = [_predictionMeta, "lineTraceStatus", []] call PHEN_CS_fnc_CSS_getPairValue;
    private _traceEndASL = [_predictionMeta, "traceEndASL", []] call PHEN_CS_fnc_CSS_getPairValue;
    private _traceEndVelocity = [_predictionMeta, "traceEndVelocity", []] call PHEN_CS_fnc_CSS_getPairValue;
    private _rocketPhaseAtLaunch = if (_projectileFamily in ["rocket", "missile"]) then { [0, _rocketData] call PHEN_CS_fnc_CSS_getRocketPhase } else { "" };
    private _rocketActiveWindow = if ((count _rocketData) >= 2) then { [_rocketData # 0, (_rocketData # 0) + (_rocketData # 1)] } else { [] };
    private _shotContext = [
        ["shotId", _shotId],
        ["shotTickTime", _shotTickTime],
        ["shotFrameNo", _shotFrameNo],
        ["weapon", _weapon],
        ["muzzle", _muzzle],
        ["mode", _mode],
        ["magazine", _magazine],
        ["ammo", _ammo],
        ["unitPosASL", _unitPosASL],
        ["eyePosASL", _eyePosASL],
        ["eyeDirection", _eyeDirection],
        ["weaponDirection", _weaponDirection],
        ["projectileStartASL", _projectileStartASL],
        ["projectileVelocity", _projectileVelocity],
        ["firedFrame0ASL", _projectileStartASL],
        ["firedFrame0Velocity", _projectileVelocity],
        ["shotInfo", _shotInfo],
        ["projectileFamily", _projectileFamily],
        ["simulation", [_ballisticProfile, "simulation", ""] call PHEN_CS_fnc_CSS_getPairValue],
        ["speed", [_ballisticProfile, "speed", 0] call PHEN_CS_fnc_CSS_getPairValue],
        ["airFriction", [_ballisticProfile, "airFriction", 0] call PHEN_CS_fnc_CSS_getPairValue],
        ["gravityCoef", [_ballisticProfile, "gravityCoef", 1] call PHEN_CS_fnc_CSS_getPairValue],
        ["timeToLive", [_ballisticProfile, "timeToLive", 0] call PHEN_CS_fnc_CSS_getPairValue],
        ["rocketData", _rocketData],
        ["rocketPhaseAtLaunch", _rocketPhaseAtLaunch],
        ["rocketActiveWindow", _rocketActiveWindow],
        ["initTime", [_ballisticProfile, "initTime", 0] call PHEN_CS_fnc_CSS_getPairValue],
        ["rocketConfigInitTime", [_ballisticProfile, "rocketConfigInitTime", [_ballisticProfile, "initTime", 0] call PHEN_CS_fnc_CSS_getPairValue] call PHEN_CS_fnc_CSS_getPairValue],
        ["rocketPredictiveInitTime", [_ballisticProfile, "rocketPredictiveInitTime", [_ballisticProfile, "initTime", 0] call PHEN_CS_fnc_CSS_getPairValue] call PHEN_CS_fnc_CSS_getPairValue],
        ["rocketPhaseNormalization", [_ballisticProfile, "rocketPhaseNormalization", "raw_config"] call PHEN_CS_fnc_CSS_getPairValue],
        ["thrustTime", [_ballisticProfile, "thrustTime", 0] call PHEN_CS_fnc_CSS_getPairValue],
        ["thrust", [_ballisticProfile, "thrust", 0] call PHEN_CS_fnc_CSS_getPairValue],
        ["maxSpeed", [_ballisticProfile, "maxSpeed", 0] call PHEN_CS_fnc_CSS_getPairValue],
        ["sideAirFriction", [_ballisticProfile, "sideAirFriction", 0] call PHEN_CS_fnc_CSS_getPairValue],
        ["predictionQuality", _predictionQuality],
        ["simulationStep", _simulationStep],
        ["discreteDistance", [_ballisticProfile, "discreteDistance", []] call PHEN_CS_fnc_CSS_getPairValue],
        ["zeroing", _zeroing],
        ["zeroDistance", _zeroDistance],
        ["activeZeroDistance", [_predictionMeta, "activeZeroDistance", _zeroDistance] call PHEN_CS_fnc_CSS_getPairValue],
        ["preShotUncorrectedAimPointASL", _preShotUncorrectedAimPointASL],
        ["preShotCorrectedAimPointASL", _preShotCorrectedAimPointASL],
        ["predictedImpactASL", _preShotCorrectedAimPointASL],
        ["uncorrectedImpactASL", _preShotUncorrectedAimPointASL],
        ["lineTraceHitASL", _lineTraceHitASL],
        ["lineTraceStatus", _lineTraceStatus],
        ["traceEndASL", _traceEndASL],
        ["traceEndVelocity", _traceEndVelocity],
        ["zeroingAngle", [_predictionMeta, "zeroingAngle", 0] call PHEN_CS_fnc_CSS_getPairValue],
        ["timeOfFlight", [_predictionMeta, "traceTimeOfFlight", -1] call PHEN_CS_fnc_CSS_getPairValue],
        ["traceSteps", [_predictionMeta, "traceSteps", -1] call PHEN_CS_fnc_CSS_getPairValue],
        ["calibrationApplied", [_predictionMeta, "calibrationApplied", false] call PHEN_CS_fnc_CSS_getPairValue],
        ["calibrationAvailable", [_predictionMeta, "calibrationAvailable", false] call PHEN_CS_fnc_CSS_getPairValue],
        ["calibrationSkippedReason", [_predictionMeta, "calibrationSkippedReason", ""] call PHEN_CS_fnc_CSS_getPairValue],
        ["calibrationSourceZeroDistance", [_predictionMeta, "calibrationSourceZeroDistance", -1] call PHEN_CS_fnc_CSS_getPairValue],
        ["calibrationSharedAcrossZeroing", [_predictionMeta, "calibrationSharedAcrossZeroing", false] call PHEN_CS_fnc_CSS_getPairValue],
        ["impactSelectionMethod", [_predictionMeta, "impactSelectionMethod", ""] call PHEN_CS_fnc_CSS_getPairValue],
        ["launchFramePredictionApplied", _launchFramePredictionApplied],
        ["launchFramePredictionReason", _launchFramePredictionReason],
        ["launchFrameAimFrame", _launchFrameAimFrame],
        ["launchFrameTraceEndASL", _launchFrameTraceEndASL],
        ["launchFrameTraceEndVelocity", _launchFrameTraceEndVelocity],
        ["trajectoryIgnoredHitCount", [_predictionMeta, "trajectoryIgnoredHitCount", 0] call PHEN_CS_fnc_CSS_getPairValue],
        ["trajectoryFirstIgnoredHit", [_predictionMeta, "trajectoryFirstIgnoredHit", []] call PHEN_CS_fnc_CSS_getPairValue],
        ["trajectoryIgnoredHitReason", [_predictionMeta, "trajectoryIgnoredHitReason", ""] call PHEN_CS_fnc_CSS_getPairValue],
        ["preShotCorrectionDistance", _preShotCorrectionDistance],
        ["preShotCorrectionDeltaASL", _preShotCorrectionDeltaASL],
        ["preShotCorrection", _predictionMeta],
        ["correction", _predictionMeta],
        ["preCorrectionAimFrame", _preCorrectionAimFrame],
        ["rawAimFrame", _rawAimFrame],
        ["rawAimDirection", _rawAimDirection],
        ["zeroedAimFrame", _zeroedAimFrame],
        ["zeroedAimDirection", _zeroedAimDirection],
        ["correctedAimFrame", _correctedAimFrame],
        ["correctedAimDirection", _correctedAimDirection],
        ["rawDirectionError", _rawDirectionError],
        ["zeroedDirectionError", _zeroedDirectionError],
        ["calibrationBaseMode", if ((count _calibration) > 8) then { _calibration # 8 } else { "" }],
        ["calibration", _calibration],
        ["prediction", _prediction]
    ];

    PHEN_CS_CSS_LastShotContext = [_shotId, _shotContext, diag_tickTime];
    PHEN_CS_CSS_LastProjectileImpactState = ["fired", [], diag_tickTime, _shotId];
    ["fired", _shotContext] call PHEN_CS_fnc_CSS_logShotContext;
    ["fired", _shotContext] call PHEN_CS_fnc_CSS_logShotAim;
    ["fired", _shotContext] call PHEN_CS_fnc_CSS_setPostShotDebugState;

    ["fired", [
        ["shotId", _shotId],
        ["shotTickTime", _shotTickTime],
        ["shotFrameNo", _shotFrameNo],
        ["weapon", _weapon],
        ["muzzle", _muzzle],
        ["mode", _mode],
        ["magazine", _magazine],
        ["ammo", _ammo],
        ["projectileFamily", _projectileFamily],
        ["simulation", [_ballisticProfile, "simulation", ""] call PHEN_CS_fnc_CSS_getPairValue],
        ["speed", [_ballisticProfile, "speed", 0] call PHEN_CS_fnc_CSS_getPairValue],
        ["airFriction", [_ballisticProfile, "airFriction", 0] call PHEN_CS_fnc_CSS_getPairValue],
        ["gravityCoef", [_ballisticProfile, "gravityCoef", 1] call PHEN_CS_fnc_CSS_getPairValue],
        ["timeToLive", [_ballisticProfile, "timeToLive", 0] call PHEN_CS_fnc_CSS_getPairValue],
        ["rocketData", _rocketData],
        ["rocketPhaseAtLaunch", _rocketPhaseAtLaunch],
        ["rocketActiveWindow", _rocketActiveWindow],
        ["initTime", [_ballisticProfile, "initTime", 0] call PHEN_CS_fnc_CSS_getPairValue],
        ["rocketConfigInitTime", [_ballisticProfile, "rocketConfigInitTime", [_ballisticProfile, "initTime", 0] call PHEN_CS_fnc_CSS_getPairValue] call PHEN_CS_fnc_CSS_getPairValue],
        ["rocketPredictiveInitTime", [_ballisticProfile, "rocketPredictiveInitTime", [_ballisticProfile, "initTime", 0] call PHEN_CS_fnc_CSS_getPairValue] call PHEN_CS_fnc_CSS_getPairValue],
        ["rocketPhaseNormalization", [_ballisticProfile, "rocketPhaseNormalization", "raw_config"] call PHEN_CS_fnc_CSS_getPairValue],
        ["thrustTime", [_ballisticProfile, "thrustTime", 0] call PHEN_CS_fnc_CSS_getPairValue],
        ["thrust", [_ballisticProfile, "thrust", 0] call PHEN_CS_fnc_CSS_getPairValue],
        ["maxSpeed", [_ballisticProfile, "maxSpeed", 0] call PHEN_CS_fnc_CSS_getPairValue],
        ["sideAirFriction", [_ballisticProfile, "sideAirFriction", 0] call PHEN_CS_fnc_CSS_getPairValue],
        ["simulationStep", _simulationStep],
        ["discreteDistance", [_ballisticProfile, "discreteDistance", []] call PHEN_CS_fnc_CSS_getPairValue],
        ["zeroDistance", _zeroDistance],
        ["activeZeroDistance", [_predictionMeta, "activeZeroDistance", _zeroDistance] call PHEN_CS_fnc_CSS_getPairValue],
        ["predictedImpactASL", _preShotCorrectedAimPointASL],
        ["uncorrectedImpactASL", _preShotUncorrectedAimPointASL],
        ["lineTraceHitASL", _lineTraceHitASL],
        ["lineTraceStatus", _lineTraceStatus],
        ["traceEndASL", _traceEndASL],
        ["traceEndVelocity", _traceEndVelocity],
        ["zeroingAngle", [_predictionMeta, "zeroingAngle", 0] call PHEN_CS_fnc_CSS_getPairValue],
        ["timeOfFlight", [_predictionMeta, "traceTimeOfFlight", -1] call PHEN_CS_fnc_CSS_getPairValue],
        ["traceSteps", [_predictionMeta, "traceSteps", -1] call PHEN_CS_fnc_CSS_getPairValue],
        ["calibrationApplied", [_predictionMeta, "calibrationApplied", false] call PHEN_CS_fnc_CSS_getPairValue],
        ["calibrationAvailable", [_predictionMeta, "calibrationAvailable", false] call PHEN_CS_fnc_CSS_getPairValue],
        ["calibrationSkippedReason", [_predictionMeta, "calibrationSkippedReason", ""] call PHEN_CS_fnc_CSS_getPairValue],
        ["calibrationSourceZeroDistance", [_predictionMeta, "calibrationSourceZeroDistance", -1] call PHEN_CS_fnc_CSS_getPairValue],
        ["calibrationSharedAcrossZeroing", [_predictionMeta, "calibrationSharedAcrossZeroing", false] call PHEN_CS_fnc_CSS_getPairValue],
        ["impactSelectionMethod", [_predictionMeta, "impactSelectionMethod", ""] call PHEN_CS_fnc_CSS_getPairValue],
        ["launchFramePredictionApplied", _launchFramePredictionApplied],
        ["launchFramePredictionReason", _launchFramePredictionReason],
        ["launchFrameAimFrame", _launchFrameAimFrame],
        ["trajectoryIgnoredHitCount", [_predictionMeta, "trajectoryIgnoredHitCount", 0] call PHEN_CS_fnc_CSS_getPairValue],
        ["trajectoryFirstIgnoredHit", [_predictionMeta, "trajectoryFirstIgnoredHit", []] call PHEN_CS_fnc_CSS_getPairValue],
        ["trajectoryIgnoredHitReason", [_predictionMeta, "trajectoryIgnoredHitReason", ""] call PHEN_CS_fnc_CSS_getPairValue],
        ["firedFrame0ASL", _projectileStartASL],
        ["firedFrame0Velocity", _projectileVelocity],
        ["prediction", _prediction]
    ]] call PHEN_CS_fnc_CSS_logShotPrediction;

    if (isNull _projectile) exitWith { false };

    _projectile setVariable ["PHEN_CS_CSS_ShotId", _shotId, false];
    _projectile addEventHandler ["HitPart", {
        PHEN_CS_CSS_LastProjectileImpactState = ["HitPart", _this, diag_tickTime, [_this] call PHEN_CS_fnc_CSS_getProjectileEventShotId];
    }];
    _projectile addEventHandler ["Deflected", {
        PHEN_CS_CSS_LastProjectileImpactState = ["Deflected", _this, diag_tickTime, [_this] call PHEN_CS_fnc_CSS_getProjectileEventShotId];
    }];
    _projectile addEventHandler ["Penetrated", {
        PHEN_CS_CSS_LastProjectileImpactState = ["Penetrated", _this, diag_tickTime, [_this] call PHEN_CS_fnc_CSS_getProjectileEventShotId];
    }];
    _projectile addEventHandler ["HitExplosion", {
        PHEN_CS_CSS_LastProjectileImpactState = ["HitExplosion", _this, diag_tickTime, [_this] call PHEN_CS_fnc_CSS_getProjectileEventShotId];
    }];
    _projectile addEventHandler ["Explode", {
        PHEN_CS_CSS_LastProjectileImpactState = ["Explode", _this, diag_tickTime, [_this] call PHEN_CS_fnc_CSS_getProjectileEventShotId];
    }];

    [_shotId, _shotTickTime, _shotFrameNo, _projectile, _prediction, _weapon, _muzzle, _mode, _ammo, _magazine, _projectileFamily, _simulationStep, _rocketData] spawn {
        params ["_shotId", "_shotTickTime", "_shotFrameNo", "_projectile", "_prediction", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectileFamily", "_simulationStep", "_rocketData"];

        private _lastASL = [];
        private _lastVelocity = [];
        private _firedFrame0ASL = [];
        private _firedFrame0Velocity = [];
        private _deadline = diag_tickTime + 8;
        private _shotStart = diag_tickTime;
        private _frame = 0;

        while { !isNull _projectile && { diag_tickTime < _deadline } } do {
            _lastASL = getPosASL _projectile;
            _lastVelocity = velocity _projectile;
            private _frameTime = diag_tickTime - _shotStart;
            if (_frame isEqualTo 0) then {
                _firedFrame0ASL = _lastASL;
                _firedFrame0Velocity = _lastVelocity;
            };
            ["frame", [
                ["shotId", _shotId],
                ["shotTickTime", _shotTickTime],
                ["shotFrameNo", _shotFrameNo],
                ["frame", _frame],
                ["t", _frameTime],
                ["weapon", _weapon],
                ["muzzle", _muzzle],
                ["mode", _mode],
                ["magazine", _magazine],
                ["ammo", _ammo],
                ["projectileFamily", _projectileFamily],
                ["simulationStep", _simulationStep],
                ["rocketPhase", if (_projectileFamily in ["rocket", "missile"]) then { [_frameTime, _rocketData] call PHEN_CS_fnc_CSS_getRocketPhase } else { "" }],
                ["posASL", _lastASL],
                ["velocity", _lastVelocity]
            ]] call PHEN_CS_fnc_CSS_logShotTraceFrame;
            _frame = _frame + 1;
            uiSleep 0;
        };

        private _predictedASL = if (_prediction isEqualType [] && { (count _prediction) > 0 }) then { _prediction # 0 } else { [] };
        private _predictionMeta = [_prediction] call PHEN_CS_fnc_CSS_getAimSolutionMeta;
        private _preShotUncorrectedAimPointASL = [_predictionMeta, "preCorrectionAimPointASL", []] call PHEN_CS_fnc_CSS_getPairValue;
        private _preShotCorrectedAimPointASL = _predictedASL;
        private _impactState = +PHEN_CS_CSS_LastProjectileImpactState;
        private _impactStateShotId = if (_impactState isEqualType [] && { (count _impactState) > 3 }) then { _impactState # 3 } else { "" };
        private _impactPosASL = [_impactState] call PHEN_CS_fnc_CSS_getImpactEventPosition;
        private _impactDistanceFromTraceEnd = -1;
        if (_impactPosASL isEqualType [] && { (count _impactPosASL) >= 3 } && { _lastASL isEqualType [] } && { (count _lastASL) >= 3 }) then {
            _impactDistanceFromTraceEnd = _impactPosASL distance _lastASL;
        };

        private _impactEvaluation = [_impactState, _prediction, _lastASL] call PHEN_CS_fnc_CSS_getImpactEvaluation;
        private _predictionErrorUsable = [_impactEvaluation] call PHEN_CS_fnc_CSS_shouldReportPredictionError;
        private _predictionErrorTargetASL = if (_impactPosASL isEqualType [] && { (count _impactPosASL) >= 3 }) then { _impactPosASL } else { _lastASL };
        private _predictionError = -1;
        if (_predictionErrorUsable && { _predictedASL isEqualType [] } && { (count _predictedASL) >= 3 } && { _predictionErrorTargetASL isEqualType [] } && { (count _predictionErrorTargetASL) >= 3 }) then {
            _predictionError = _predictedASL distance _predictionErrorTargetASL;
        };
        private _impactVsCorrectedVectorASL = [];
        if (_predictionErrorUsable && { _predictedASL isEqualType [] } && { (count _predictedASL) >= 3 } && { _predictionErrorTargetASL isEqualType [] } && { (count _predictionErrorTargetASL) >= 3 }) then {
            _impactVsCorrectedVectorASL = _predictionErrorTargetASL vectorAdd (_predictedASL vectorMultiply -1);
        };

        ["trace_end", [
            ["shotId", _shotId],
            ["shotTickTime", _shotTickTime],
            ["shotFrameNo", _shotFrameNo],
            ["weapon", _weapon],
            ["muzzle", _muzzle],
            ["mode", _mode],
            ["magazine", _magazine],
            ["ammo", _ammo],
            ["projectileFamily", _projectileFamily],
            ["simulationStep", _simulationStep],
            ["rocketData", _rocketData],
            ["rocketPhaseAtTraceEnd", if (_projectileFamily in ["rocket", "missile"]) then { [diag_tickTime - _shotStart, _rocketData] call PHEN_CS_fnc_CSS_getRocketPhase } else { "" }],
            ["firedFrame0ASL", _firedFrame0ASL],
            ["firedFrame0Velocity", _firedFrame0Velocity],
            ["lastASL", _lastASL],
            ["lastVelocity", _lastVelocity],
            ["prediction", _prediction],
            ["preShotUncorrectedAimPointASL", _preShotUncorrectedAimPointASL],
            ["preShotCorrectedAimPointASL", _preShotCorrectedAimPointASL],
            ["lineTraceHitASL", [_predictionMeta, "lineTraceHitASL", []] call PHEN_CS_fnc_CSS_getPairValue],
            ["traceEndASL", [_predictionMeta, "traceEndASL", []] call PHEN_CS_fnc_CSS_getPairValue],
            ["traceEndVelocity", [_predictionMeta, "traceEndVelocity", []] call PHEN_CS_fnc_CSS_getPairValue],
            ["impactSelectionMethod", [_predictionMeta, "impactSelectionMethod", ""] call PHEN_CS_fnc_CSS_getPairValue],
            ["postShotImpactPointASL", _predictionErrorTargetASL],
            ["predictionError", _predictionError],
            ["predictionErrorTargetASL", _predictionErrorTargetASL],
            ["impactVsCorrectedError", _predictionError],
            ["impactVsCorrectedVectorASL", _impactVsCorrectedVectorASL],
            ["preShotCorrection", _predictionMeta],
            ["impactEvaluation", _impactEvaluation],
            ["predictionErrorUsable", _predictionErrorUsable],
            ["impactPosASL", _impactPosASL],
            ["impactDistanceFromTraceEnd", _impactDistanceFromTraceEnd],
            ["impactStateShotId", _impactStateShotId],
            ["impactStateShotIdMatch", (_impactStateShotId isEqualTo "") || { _impactStateShotId isEqualTo _shotId }],
            ["impactState", _impactState]
        ]] call PHEN_CS_fnc_CSS_setPostShotDebugState;
    };

    false
};

PHEN_CS_fnc_CSS_registerFiredDebugEH = {
    if (isNil { missionNamespace getVariable "PHEN_CS_CSS_FiredDebugEH" }) then {
        missionNamespace setVariable ["PHEN_CS_CSS_FiredDebugEH", player addEventHandler ["FiredMan", {
            _this call PHEN_CS_fnc_CSS_onFiredDebug;
        }]];
    };
};

PHEN_CS_fnc_CSS_updateAimPrediction = {
    if !(call PHEN_CS_fnc_CSS_hasSuite) exitWith { ["no_suite", []] call PHEN_CS_fnc_CSS_clearAimSolution; };

    private _unit = call PHEN_CS_fnc_CSS_getUnit;
    if (isNull _unit || { !alive _unit }) exitWith { ["invalid_unit", []] call PHEN_CS_fnc_CSS_clearAimSolution; };
    if !(isNull (objectParent _unit)) exitWith { ["in_vehicle", []] call PHEN_CS_fnc_CSS_clearAimSolution; };

    private _state = weaponState _unit;
    _state params ["_weapon", "_muzzle", "_mode", "_magazine", "_ammoCount"];
    if (_weapon isEqualTo "") then { _weapon = currentWeapon _unit; };
    if (_muzzle isEqualTo "") then { _muzzle = currentMuzzle _unit; };
    if (_magazine isEqualTo "") then { _magazine = currentMagazine _unit; };
    if (_weapon isEqualTo "" || { _ammoCount <= 0 }) exitWith { ["empty_weapon", [_weapon, _muzzle, _mode, _magazine, _ammoCount]] call PHEN_CS_fnc_CSS_clearAimSolution; };
    private _weaponSlot = [_unit, _weapon] call PHEN_CS_fnc_CSS_getWeaponSlot;
    if (_weaponSlot isEqualTo "unknown") exitWith { ["unsupported_weapon_slot", [_weapon, primaryWeapon _unit, handgunWeapon _unit, secondaryWeapon _unit]] call PHEN_CS_fnc_CSS_clearAimSolution; };

    private _zeroing = _unit currentZeroing [_weapon, _muzzle];
    private _zeroDistance = [_zeroing] call PHEN_CS_fnc_CSS_getZeroDistance;

    private _ballisticData = [_unit, _weapon, _muzzle, _mode, _magazine] call PHEN_CS_fnc_CSS_getBallisticData;
    if (_ballisticData isEqualTo []) exitWith { ["missing_ballistic_data", [_weapon, _muzzle, _mode, _magazine]] call PHEN_CS_fnc_CSS_clearAimSolution; };
    _ballisticData params ["_speed", "_airFriction", "_gravityCoef", "_timeToLive", "_simulation", "_isLauncher", "_isSupported", "_ammo", "_ammoCfg", "_attachmentCoefs", "_projectileFamily", "_rocketData", "_predictionQuality"];
    private _simulationStep = if ((count _ballisticData) > 13) then { _ballisticData # 13 } else { 0.025 };
    private _ballisticProfile = if ((count _ballisticData) > 14) then { +(_ballisticData # 14) } else { [] };

    private _calibrationKey = [_weapon, _muzzle, _mode, _magazine, _ammo, _zeroDistance, stance _unit, _projectileFamily] call PHEN_CS_fnc_CSS_getShotCalibrationKey;
    private _calibration = [_calibrationKey] call PHEN_CS_fnc_CSS_getShotCalibration;
    private _calibrationAvailable = !(_calibration isEqualTo []);
    private _calibrationApplied = [_calibration, _projectileFamily] call PHEN_CS_fnc_CSS_shouldApplyPredictiveCalibration;
    private _calibrationSkippedReason = if (_calibrationAvailable) then { "" } else { "no_reference" };
    if (_calibrationAvailable && { !_calibrationApplied }) then {
        _calibrationSkippedReason = if ((toLower _projectileFamily) in ["rocket", "missile", "shell"]) then {
            "family_disabled"
        } else {
            if !(missionNamespace getVariable ["PHEN_CS_CSS_UseShotCalibration", PHEN_CS_CSS_UseShotCalibration]) then {
                "setting_disabled"
            } else {
                "bias_below_threshold"
            };
        };
    };
    private _calibrationSourceZeroDistance = if ((count _calibration) > 9) then { _calibration # 9 } else { -1 };
    private _calibrationBiasMagnitude = if ((count _calibration) > 10) then { _calibration # 10 } else { -1 };
    private _calibrationSharedAcrossZeroing = if ((count _calibration) > 11) then { _calibration # 11 } else { [_projectileFamily] call PHEN_CS_fnc_CSS_calibrationSharesAcrossZeroing };
    _speed = [_speed, _calibration, _projectileFamily] call PHEN_CS_fnc_CSS_applySpeedCalibration;
    _ballisticProfile = [_ballisticProfile, "speed", _speed] call PHEN_CS_fnc_CSS_setPairValue;

    private _applyZeroing = [_unit, _weapon, _muzzle, _mode, _magazine, _ammo] call PHEN_CS_fnc_CSS_shouldApplyZeroing;
    _applyZeroing = [_projectileFamily, _applyZeroing] call PHEN_CS_fnc_CSS_shouldApplyPredictiveZeroing;
    if (_calibrationApplied) then {
        _applyZeroing = [_calibration, _applyZeroing] call PHEN_CS_fnc_CSS_calibrationWantsZeroing;
    };

    private _aimInputDir = [_unit, _weapon] call PHEN_CS_fnc_CSS_getAimInputDirection;
    private _aimCacheKey = [_unit, _weapon, _muzzle, _mode, _magazine, _ammo, _zeroDistance, _projectileFamily, _speed, _simulationStep, _applyZeroing, _calibrationApplied] call PHEN_CS_fnc_CSS_getAimCacheKey;
    private _cacheReuse = [_aimCacheKey, _aimInputDir, _projectileFamily] call PHEN_CS_fnc_CSS_getReusableAimSolution;
    _cacheReuse params ["_cacheHit", "_cachedSolution", "_aimCacheStatus", "_aimCacheAngleDeg"];
    if (_cacheHit) exitWith {
        PHEN_CS_CSS_AimSolution = _cachedSolution;
    };
    if (_aimCacheStatus isEqualTo "aim_throttled_moved") exitWith {
        ["aim_throttled_moved", [
            ["weapon", _weapon],
            ["muzzle", _muzzle],
            ["mode", _mode],
            ["magazine", _magazine],
            ["ammo", _ammo],
            ["projectileFamily", _projectileFamily],
            ["zeroDistance", _zeroDistance],
            ["aimCacheStatus", _aimCacheStatus],
            ["aimCacheAngleDeg", _aimCacheAngleDeg],
            ["aimCacheThresholdDeg", [_projectileFamily] call PHEN_CS_fnc_CSS_getAimReuseAngleDeg],
            ["aimCacheInterval", [_projectileFamily] call PHEN_CS_fnc_CSS_getAimUpdateInterval]
        ], true] call PHEN_CS_fnc_CSS_clearAimSolution;
    };

    private _aimFrame = [_unit, _weapon, _speed, _zeroDistance, _gravityCoef, _applyZeroing, _ballisticProfile] call PHEN_CS_fnc_CSS_getAimFrame;
    private _preCorrectionAimFrame = +_aimFrame;
    if (_calibrationApplied) then {
        _aimFrame = [_unit, _aimFrame, _calibration, _projectileFamily] call PHEN_CS_fnc_CSS_applyAimCalibration;
    };
    _aimFrame params ["_startASL", "_sightDir", "_weaponDir", "_viewDir", "_originMethod", "_dirMethod", "_fromWeapon", "_zeroingApplied", "_viewCoherence"];
    if ((vectorMagnitude _sightDir) <= 0.001) exitWith { ["invalid_aim_frame", [_weapon, _weaponDir, _viewDir, _originMethod, _dirMethod]] call PHEN_CS_fnc_CSS_clearAimSolution; };

    private _debugCorrection = missionNamespace getVariable ["PHEN_CS_DebugMode", false];
    private _preCorrectionHit = [];
    private _preCorrectionHitReason = "not_traced";
    private _preCorrectionAimPointASL = [];
    private _postCorrectionAimPointASL = [];
    private _correctionDeltaASL = [];
    private _correctionDistance = -1;
    private _correctionDirectionError = [-1, 0, 0, 0];
    private _correctionTelemetry = [];
    private _zeroingTelemetry = if ((count _aimFrame) > 9) then { _aimFrame # 9 } else { [] };

    private _endASL = _startASL vectorAdd (_sightDir vectorMultiply 5000);
    private _rayHits = lineIntersectsSurfaces [_startASL, _endASL, _unit, vehicle _unit, true, 1, "FIRE", "GEOM", true];
    private _rayHit = if (_rayHits isEqualTo []) then { [] } else { _rayHits # 0 };
    private _rayStatus = [_startASL, _rayHit] call PHEN_CS_fnc_CSS_getAimHitStatus;
    private _rayPosASL = if (_rayStatus # 0) then { _rayHit # 0 } else { [] };

    private _hasACEAdvancedBallistics = isClass (configFile >> "CfgPatches" >> "ace_advanced_ballistics");
    private _label = if (_hasACEAdvancedBallistics) then { "APPROX ACE" } else { "PREDICTED" };
    if (_projectileFamily in ["rocket", "missile"]) then { _label = "APPROX ROCKET"; };

    if (!_isSupported) exitWith {
        private _payload = ["launcher_no_solution", _unit, _weapon, _muzzle, _mode, _magazine, _ammo, _simulation, _speed, _airFriction, _gravityCoef, _zeroDistance, _weaponSlot, _aimFrame, _attachmentCoefs, "unsupported_projectile", ["NO SOLUTION"], _predictionQuality] call PHEN_CS_fnc_CSS_getAimDebugPayload;
        ["launcher_no_solution", _payload] call PHEN_CS_fnc_CSS_clearAimSolution;
    };

    if (_speed <= 0) exitWith {
        if !(["zero_speed", _rayStatus] call PHEN_CS_fnc_CSS_allowRayFallback) then {
            private _payload = ["no_valid_hit", _unit, _weapon, _muzzle, _mode, _magazine, _ammo, _simulation, _speed, _airFriction, _gravityCoef, _zeroDistance, _weaponSlot, _aimFrame, _attachmentCoefs, _rayStatus # 1, _rayHits, _predictionQuality] call PHEN_CS_fnc_CSS_getAimDebugPayload;
            ["no_valid_hit", _payload] call PHEN_CS_fnc_CSS_clearAimSolution;
        } else {
            PHEN_CS_CSS_AimSolution = [_rayPosASL, diag_tickTime + 0.35, "ray", "APPROX", _zeroDistance];
            private _payload = ["ray_fallback", _unit, _weapon, _muzzle, _mode, _magazine, _ammo, _simulation, _speed, _airFriction, _gravityCoef, _zeroDistance, _weaponSlot, _aimFrame, _attachmentCoefs, _rayStatus # 1, _rayHit, _predictionQuality] call PHEN_CS_fnc_CSS_getAimDebugPayload;
            ["ray_fallback", _payload] call PHEN_CS_fnc_CSS_setAimDebugState;
        };
    };

    if (_debugCorrection && { _calibrationApplied }) then {
        private _preTrace = [_unit, _preCorrectionAimFrame, _ballisticProfile, true] call PHEN_CS_fnc_CSS_traceBallisticProfile;
        _preTrace params ["_preHit", "_preHitReason"];
        _preCorrectionHit = _preHit;
        _preCorrectionHitReason = _preHitReason;
        if !(_preCorrectionHit isEqualTo []) then {
            _preCorrectionAimPointASL = _preCorrectionHit # 0;
        };
    };

    private _trace = [_unit, _aimFrame, _ballisticProfile, true] call PHEN_CS_fnc_CSS_traceBallisticProfile;
    _trace params ["_hit", "_hitReason", "_traceEndASL", "_traceEndVelocity", "_traceSteps", "_traceTimeOfFlight", "_trajectoryIgnoredHitCount", "_trajectoryFirstIgnoredHit", "_trajectoryIgnoredHitReason"];

    if !(_hit isEqualTo []) then {
        _postCorrectionAimPointASL = _hit # 0;
        if !(_calibrationApplied) then {
            _preCorrectionAimPointASL = _postCorrectionAimPointASL;
            _preCorrectionHitReason = _hitReason;
        };
    };

    if (_preCorrectionAimPointASL isEqualType [] && { (count _preCorrectionAimPointASL) >= 3 } && { _postCorrectionAimPointASL isEqualType [] } && { (count _postCorrectionAimPointASL) >= 3 }) then {
        _correctionDeltaASL = _postCorrectionAimPointASL vectorAdd (_preCorrectionAimPointASL vectorMultiply -1);
        _correctionDistance = _preCorrectionAimPointASL distance _postCorrectionAimPointASL;
    };
    if ((count _preCorrectionAimFrame) >= 2 && { (count _aimFrame) >= 2 }) then {
        _correctionDirectionError = [_preCorrectionAimFrame # 1, _aimFrame # 1] call PHEN_CS_fnc_CSS_measureDirectionError;
    };
    private _impactSelectionMethod = switch (_projectileFamily) do {
        case "shell": { "shell_trajectory_collision" };
        case "bullet": { "bullet_trajectory_collision" };
        default { "trajectory_collision" };
    };

    _correctionTelemetry = [
        ["calibrationKey", _calibrationKey],
        ["calibration", _calibration],
        ["calibrationAvailable", _calibrationAvailable],
        ["calibrationApplied", _calibrationApplied],
        ["calibrationSkippedReason", _calibrationSkippedReason],
        ["calibrationSourceZeroDistance", _calibrationSourceZeroDistance],
        ["activeZeroDistance", _zeroDistance],
        ["calibrationSharedAcrossZeroing", _calibrationSharedAcrossZeroing],
        ["calibrationBiasMagnitude", _calibrationBiasMagnitude],
        ["projectileFamily", _projectileFamily],
        ["simulationStep", _simulationStep],
        ["discreteDistance", [_ballisticProfile, "discreteDistance", []] call PHEN_CS_fnc_CSS_getPairValue],
        ["zeroingTelemetry", _zeroingTelemetry],
        ["zeroingAngle", [_zeroingTelemetry, "zeroingAngle", 0] call PHEN_CS_fnc_CSS_getPairValue],
        ["preCorrectionAimFrame", _preCorrectionAimFrame],
        ["postCorrectionAimFrame", _aimFrame],
        ["preCorrectionAimPointASL", _preCorrectionAimPointASL],
        ["postCorrectionAimPointASL", _postCorrectionAimPointASL],
        ["preCorrectionHitReason", _preCorrectionHitReason],
        ["postCorrectionHitReason", _hitReason],
        ["impactSelectionMethod", _impactSelectionMethod],
        ["lineTraceStatus", _rayStatus],
        ["lineTraceHitASL", _rayPosASL],
        ["lineTraceHitRaw", _rayHit],
        ["traceEndASL", _traceEndASL],
        ["traceEndVelocity", _traceEndVelocity],
        ["traceSteps", _traceSteps],
        ["traceTimeOfFlight", _traceTimeOfFlight],
        ["trajectoryIgnoredHitCount", _trajectoryIgnoredHitCount],
        ["trajectoryFirstIgnoredHit", _trajectoryFirstIgnoredHit],
        ["trajectoryIgnoredHitReason", _trajectoryIgnoredHitReason],
        ["correctionDeltaASL", _correctionDeltaASL],
        ["correctionDistance", _correctionDistance],
        ["correctionDirectionError", _correctionDirectionError]
    ];

    if !(_hit isEqualTo []) then {
        if (_projectileFamily in ["rocket", "missile"]) then {
            private _rocketMethod = "rocket_approx";
            PHEN_CS_CSS_AimSolution = [_aimCacheKey, _aimInputDir, _projectileFamily, [_hit # 0, diag_tickTime + PHEN_CS_CSS_AimSolutionTTL, "rocket", _label, _zeroDistance, _correctionTelemetry]] call PHEN_CS_fnc_CSS_storeAimSolutionCache;
            private _payload = [_rocketMethod, _unit, _weapon, _muzzle, _mode, _magazine, _ammo, _simulation, _speed, _airFriction, _gravityCoef, _zeroDistance, _weaponSlot, _aimFrame, _attachmentCoefs, _hitReason, _hit, _predictionQuality, _correctionTelemetry] call PHEN_CS_fnc_CSS_getAimDebugPayload;
            [_rocketMethod, _payload] call PHEN_CS_fnc_CSS_setAimDebugState;
        } else {
            if (_projectileFamily isEqualTo "shell") then {
                PHEN_CS_CSS_AimSolution = [_aimCacheKey, _aimInputDir, _projectileFamily, [_hit # 0, diag_tickTime + PHEN_CS_CSS_AimSolutionTTL, "shell_trajectory", _label, _zeroDistance, _correctionTelemetry]] call PHEN_CS_fnc_CSS_storeAimSolutionCache;
                private _payload = ["shell_trajectory_collision", _unit, _weapon, _muzzle, _mode, _magazine, _ammo, _simulation, _speed, _airFriction, _gravityCoef, _zeroDistance, _weaponSlot, _aimFrame, _attachmentCoefs, _hitReason, _hit, _predictionQuality, _correctionTelemetry] call PHEN_CS_fnc_CSS_getAimDebugPayload;
                ["shell_trajectory_collision", _payload] call PHEN_CS_fnc_CSS_setAimDebugState;
            } else {
                if (_projectileFamily isEqualTo "bullet") then {
                    PHEN_CS_CSS_AimSolution = [_aimCacheKey, _aimInputDir, _projectileFamily, [_hit # 0, diag_tickTime + PHEN_CS_CSS_AimSolutionTTL, "bullet_trajectory", _label, _zeroDistance, _correctionTelemetry]] call PHEN_CS_fnc_CSS_storeAimSolutionCache;
                    private _payload = ["bullet_trajectory_collision", _unit, _weapon, _muzzle, _mode, _magazine, _ammo, _simulation, _speed, _airFriction, _gravityCoef, _zeroDistance, _weaponSlot, _aimFrame, _attachmentCoefs, _hitReason, _hit, _predictionQuality, _correctionTelemetry] call PHEN_CS_fnc_CSS_getAimDebugPayload;
                    ["bullet_trajectory_collision", _payload] call PHEN_CS_fnc_CSS_setAimDebugState;
                } else {
                    PHEN_CS_CSS_AimSolution = [_aimCacheKey, _aimInputDir, _projectileFamily, [_hit # 0, diag_tickTime + PHEN_CS_CSS_AimSolutionTTL, "ballistic", _label, _zeroDistance, _correctionTelemetry]] call PHEN_CS_fnc_CSS_storeAimSolutionCache;
                    private _payload = ["ballistic_hit", _unit, _weapon, _muzzle, _mode, _magazine, _ammo, _simulation, _speed, _airFriction, _gravityCoef, _zeroDistance, _weaponSlot, _aimFrame, _attachmentCoefs, _hitReason, _hit, _predictionQuality, _correctionTelemetry] call PHEN_CS_fnc_CSS_getAimDebugPayload;
                    ["ballistic_hit", _payload] call PHEN_CS_fnc_CSS_setAimDebugState;
                };
            };
        };
    } else {
        private _payload = ["no_ballistic_hit", _unit, _weapon, _muzzle, _mode, _magazine, _ammo, _simulation, _speed, _airFriction, _gravityCoef, _zeroDistance, _weaponSlot, _aimFrame, _attachmentCoefs, _hitReason, [["rayStatus", _rayStatus], ["rayHits", _rayHits]], _predictionQuality, _correctionTelemetry] call PHEN_CS_fnc_CSS_getAimDebugPayload;
        ["no_ballistic_hit", _payload] call PHEN_CS_fnc_CSS_clearAimSolution;
    };
};

PHEN_CS_fnc_CSS_getAimDrawASL = {
    params ["_unit", "_impactPosASL"];

    if (isNull _unit || { !(_impactPosASL isEqualType []) } || { (count _impactPosASL) < 3 }) exitWith { [] };
    private _lift = missionNamespace getVariable ["PHEN_CS_CSS_AimDrawSurfaceLift", PHEN_CS_CSS_AimDrawSurfaceLift];
    private _viewOriginASL = eyePos _unit;
    private _toCamera = _viewOriginASL vectorDiff _impactPosASL;
    if ((vectorMagnitude _toCamera) > 0.1) exitWith {
        _impactPosASL vectorAdd ((vectorNormalized _toCamera) vectorMultiply _lift)
    };

    _impactPosASL vectorAdd [0, 0, _lift]
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
            private _drawASL = [_unit, _impactPosASL] call PHEN_CS_fnc_CSS_getAimDrawASL;
            if (_drawASL isEqualTo []) exitWith {};
            private _color = if (_method isEqualTo "ballistic") then { [0.2,0.85,1,0.9] } else { [1,0.72,0.1,0.78] };
            drawIcon3D ["\a3\ui_f\data\map\markers\military\destroy_ca.paa", _color, ASLToAGL _drawASL, 0.72 * _hudScale, 0.72 * _hudScale, 0, _label, 1, 0.032 * _hudScale, "RobotoCondensed", "center", false];
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

    call PHEN_CS_fnc_CSS_registerFiredDebugEH;
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
