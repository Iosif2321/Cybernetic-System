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
PHEN_CS_CSS_ImpactMatchTolerance = 75;
PHEN_CS_CSS_MaxRadarContacts = 32;
PHEN_CS_CSS_AimSolution = [];
PHEN_CS_CSS_AimDebugState = ["init", [], 0];
PHEN_CS_CSS_AimDebugLastLog = 0;
PHEN_CS_CSS_PostShotDebugState = ["init", [], 0];
PHEN_CS_CSS_PostShotDebugLastLog = 0;
PHEN_CS_CSS_ShotCalibration = [];
PHEN_CS_CSS_LastProjectileImpactState = ["init", [], 0];
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

PHEN_CS_fnc_CSS_getRocketAccel = {
    params [["_dir", [0,0,0]], ["_vel", [0,0,0]], ["_elapsed", 0], ["_rocketData", []], ["_airFriction", 0]];

    _rocketData params [["_initTime", 0], ["_thrustTime", 0], ["_thrust", 0], ["_maxSpeed", 0], ["_sideAirFriction", 0]];

    private _speedNow = vectorMagnitude _vel;
    private _forward = if (_speedNow > 0.1) then { vectorNormalized _vel } else { vectorNormalized _dir };
    private _accel = [0,0,0];

    if (_elapsed >= _initTime && { _elapsed <= (_initTime + _thrustTime) } && { _thrust != 0 }) then {
        _accel = _accel vectorAdd (_forward vectorMultiply _thrust);
    };

    if (_airFriction != 0 && { _speedNow > 0 }) then {
        _accel = _accel vectorAdd (_vel vectorMultiply (_speedNow * _airFriction));
    };

    if (_sideAirFriction != 0 && { _speedNow > 0 }) then {
        private _forwardComponent = _forward vectorMultiply (_vel vectorDotProduct _forward);
        private _sideVel = _vel vectorAdd (_forwardComponent vectorMultiply -1);
        _accel = _accel vectorAdd (_sideVel vectorMultiply ((abs _sideAirFriction) * -1 * _speedNow));
    };

    [_accel, _maxSpeed]
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
    params ["_unit", "_weapon", "_speed", "_zeroDistance", "_gravityCoef", ["_applyZeroing", true]];

    private _weaponDir = vectorNormalized (_unit weaponDirection _weapon);
    private _fromWeapon = (vectorMagnitude _weaponDir) > 0.001;
    private _viewDir = [_unit] call PHEN_CS_fnc_CSS_getViewDirection;
    private _dir = if (_fromWeapon) then { _weaponDir } else { _viewDir };
    private _dirMethod = if (_fromWeapon) then { "weaponDirection" } else { "viewDirection" };
    private _zeroingApplied = false;

    if (_applyZeroing && { _speed > 0 } && { _zeroDistance > 0 }) then {
        _dir = [_dir, _speed, _zeroDistance, _gravityCoef] call PHEN_CS_fnc_CSS_applyZeroing;
        _zeroingApplied = true;
    };
    _dir = vectorNormalized _dir;

    private _originData = [_unit, _dir] call PHEN_CS_fnc_CSS_getAimOrigin;
    _originData params ["_originASL", "_originMethod"];

    private _viewCoherence = -1;
    if ((vectorMagnitude _weaponDir) > 0.001 && { (vectorMagnitude _viewDir) > 0.001 }) then {
        _viewCoherence = _weaponDir vectorDotProduct _viewDir;
    };

    [_originASL, _dir, _weaponDir, _viewDir, _originMethod, _dirMethod, _fromWeapon, _zeroingApplied, _viewCoherence]
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
    private _projectileFamily = [_simulation, _isLauncher] call PHEN_CS_fnc_CSS_getProjectileFamily;
    private _isSupported = _projectileFamily in ["bullet", "shell", "rocket"];
    private _attachmentCoefs = [_unit, _weapon] call PHEN_CS_fnc_CSS_getAttachmentCoefs;
    _attachmentCoefs params ["_slot", "_muzzleAttachment", "_initSpeedCoef", "_airFrictionCoef", "_typicalSpeedCoef"];

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
    private _rocketData = [_initTime, _thrustTime, _thrust, _maxSpeed, _sideAirFriction];
    private _predictionQuality = switch (_projectileFamily) do {
        case "bullet": { "ballistic" };
        case "shell": { "ballistic" };
        case "rocket": { "rocket_approx" };
        default { "unsupported" };
    };

    _speed = _speed * _initSpeedCoef * _typicalSpeedCoef;
    _airFriction = _airFriction * _airFrictionCoef;

    [_speed, _airFriction, _gravityCoef, _timeToLive, _simulation, _isLauncher, _isSupported, _ammo, _ammoCfg, _attachmentCoefs, _projectileFamily, _rocketData, _predictionQuality]
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

PHEN_CS_fnc_CSS_allowRayFallback = {
    params ["_reason", "_rayStatus"];

    (_reason isEqualTo "zero_speed") && { (_rayStatus # 0) }
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

PHEN_CS_fnc_CSS_getShotCalibrationKey = {
    params ["_weapon", "_muzzle", "_mode", "_magazine", "_ammo", "_zeroDistance", "_stanceName"];

    format ["%1|%2|%3|%4|%5|%6|%7", _weapon, _muzzle, _mode, _magazine, _ammo, round _zeroDistance, _stanceName]
};

PHEN_CS_fnc_CSS_getShotCalibration = {
    params ["_key"];

    private _idx = PHEN_CS_CSS_ShotCalibration findIf { (_x # 0) isEqualTo _key };
    if (_idx < 0) exitWith { [] };
    (PHEN_CS_CSS_ShotCalibration # _idx) # 1
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

PHEN_CS_fnc_CSS_storeShotCalibration = {
    params ["_unit", "_weapon", "_muzzle", "_mode", "_magazine", "_ammo", "_zeroDistance", "_aimFrame", "_projectileStartASL", "_projectileVelocity", ["_baseMode", "zeroed"]];

    if (isNull _unit || { (count _aimFrame) < 2 }) exitWith { [] };
    if !(_projectileStartASL isEqualType [] && { (count _projectileStartASL) >= 3 }) exitWith { [] };
    if !(_projectileVelocity isEqualType [] && { (count _projectileVelocity) >= 3 } && { (vectorMagnitude _projectileVelocity) > 0.1 }) exitWith { [] };

    private _stanceName = stance _unit;
    private _key = [_weapon, _muzzle, _mode, _magazine, _ammo, _zeroDistance, _stanceName] call PHEN_CS_fnc_CSS_getShotCalibrationKey;
    private _originLocal = _unit worldToModelVisual (ASLToAGL _projectileStartASL);
    private _predictedDir = _aimFrame # 1;
    private _actualDir = vectorNormalized _projectileVelocity;
    private _dirError = [_predictedDir, _actualDir] call PHEN_CS_fnc_CSS_measureDirectionError;
    _dirError params ["_angleDeg", "_lateralBias", "_verticalBias", "_dot"];

    private _value = [_originLocal, _lateralBias, _verticalBias, _angleDeg, _dot, vectorMagnitude _projectileVelocity, diag_tickTime, _key, _baseMode];
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

PHEN_CS_fnc_CSS_applySpeedCalibration = {
    params ["_speed", "_calibration"];

    if !(_calibration isEqualType []) exitWith { _speed };
    if ((count _calibration) <= 5) exitWith { _speed };

    private _calibratedSpeed = _calibration # 5;
    if !(_calibratedSpeed isEqualType 0) exitWith { _speed };
    if (_calibratedSpeed <= 1) exitWith { _speed };

    _calibratedSpeed
};

PHEN_CS_fnc_CSS_applyAimCalibration = {
    params ["_unit", "_aimFrame", "_calibration"];

    if !(missionNamespace getVariable ["PHEN_CS_CSS_UseShotCalibration", true]) exitWith { _aimFrame };
    if ((count _aimFrame) < 9 || { (count _calibration) < 3 }) exitWith { _aimFrame };

    _aimFrame params ["_originASL", "_dir", "_weaponDir", "_viewDir", "_originMethod", "_dirMethod", "_fromWeapon", "_zeroingApplied", "_viewCoherence"];
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

    [_originASL, _dir, _weaponDir, _viewDir, _originMethod, _dirMethod, _fromWeapon, _zeroingApplied, _viewCoherence]
};

PHEN_CS_fnc_CSS_shouldApplyZeroing = {
    params ["_unit", "_weapon", "_muzzle", "_mode", "_magazine", "_ammo"];

    private _policy = missionNamespace getVariable ["PHEN_CS_CSS_ZeroingPolicy", "apply"];
    if (_policy isEqualType false) exitWith { _policy };
    if !(_policy isEqualType "") exitWith { true };

    private _normalized = toLower _policy;
    !(_normalized in ["none", "never", "off", "disabled"])
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

PHEN_CS_fnc_CSS_logAimDebug = {
    params [["_reason", ""], ["_data", []]];

    if !(missionNamespace getVariable ["PHEN_CS_DebugMode", false]) exitWith { false };
    if (diag_tickTime < (PHEN_CS_CSS_AimDebugLastLog + 0.75)) exitWith { false };

    PHEN_CS_CSS_AimDebugLastLog = diag_tickTime;
    diag_log format ["[PHEN_CS][ArgusAim] %1 | %2", _reason, _data];
    false
};

PHEN_CS_fnc_CSS_setAimDebugState = {
    params [["_reason", ""], ["_data", []]];

    PHEN_CS_CSS_AimDebugState = [_reason, _data, diag_tickTime];
    [_reason, _data] call PHEN_CS_fnc_CSS_logAimDebug;
    false
};

PHEN_CS_fnc_CSS_clearAimSolution = {
    params [["_reason", ""], ["_data", []]];

    PHEN_CS_CSS_AimSolution = [];
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
        ["_predictionQuality", ""]
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
        ["viewCoherence", _viewCoherence],
        ["attachmentCoefs", _attachmentCoefs],
        ["predictionQuality", _predictionQuality],
        ["hitReason", _hitReason],
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
                _usable = false;
                _scoreable = false;
                _reason = "impact_position_unavailable";
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

PHEN_CS_fnc_CSS_logPostShotDebug = {
    params [["_reason", ""], ["_data", []]];

    if !(missionNamespace getVariable ["PHEN_CS_DebugMode", false]) exitWith { false };
    if (diag_tickTime < (PHEN_CS_CSS_PostShotDebugLastLog + 0.75)) exitWith { false };

    PHEN_CS_CSS_PostShotDebugLastLog = diag_tickTime;
    diag_log format ["[PHEN_CS][ArgusShot] %1 | %2", _reason, _data];
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

    private _prediction = +PHEN_CS_CSS_AimSolution;
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

    if !(_ballisticData isEqualTo []) then {
        _ballisticData params ["_speed", "_airFriction", "_gravityCoef", "_timeToLive", "_simulation", "_isLauncher", "_isSupported", "_dataAmmo", "_ammoCfg", "_attachmentCoefs", "_projectileFamilyValue", "_rocketDataValue", "_predictionQualityValue"];
        _projectileFamily = _projectileFamilyValue;
        _rocketData = _rocketDataValue;
        _predictionQuality = _predictionQualityValue;
        _rawAimFrame = [_unit, _weapon, _speed, _zeroDistance, _gravityCoef, false] call PHEN_CS_fnc_CSS_getAimFrame;
        _zeroedAimFrame = [_unit, _weapon, _speed, _zeroDistance, _gravityCoef, true] call PHEN_CS_fnc_CSS_getAimFrame;

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

                _calibration = [_unit, _weapon, _muzzle, _mode, _magazine, _ammo, _zeroDistance, _chosenAimFrame, _projectileStartASL, _projectileVelocity, _chosenBaseMode] call PHEN_CS_fnc_CSS_storeShotCalibration;
            };
        };
    };

    PHEN_CS_CSS_LastProjectileImpactState = ["fired", [], diag_tickTime];

    ["fired", [
        ["weapon", _weapon],
        ["muzzle", _muzzle],
        ["mode", _mode],
        ["magazine", _magazine],
        ["ammo", _ammo],
        ["projectileStartASL", _projectileStartASL],
        ["projectileVelocity", _projectileVelocity],
        ["shotInfo", _shotInfo],
        ["projectileFamily", _projectileFamily],
        ["rocketData", _rocketData],
        ["predictionQuality", _predictionQuality],
        ["zeroing", _zeroing],
        ["zeroDistance", _zeroDistance],
        ["rawAimFrame", _rawAimFrame],
        ["zeroedAimFrame", _zeroedAimFrame],
        ["rawDirectionError", _rawDirectionError],
        ["zeroedDirectionError", _zeroedDirectionError],
        ["calibrationBaseMode", if ((count _calibration) > 8) then { _calibration # 8 } else { "" }],
        ["calibration", _calibration],
        ["prediction", _prediction]
    ]] call PHEN_CS_fnc_CSS_setPostShotDebugState;

    if (isNull _projectile) exitWith { false };

    _projectile addEventHandler ["HitPart", {
        PHEN_CS_CSS_LastProjectileImpactState = ["HitPart", _this, diag_tickTime];
    }];
    _projectile addEventHandler ["Deflected", {
        PHEN_CS_CSS_LastProjectileImpactState = ["Deflected", _this, diag_tickTime];
    }];
    _projectile addEventHandler ["Penetrated", {
        PHEN_CS_CSS_LastProjectileImpactState = ["Penetrated", _this, diag_tickTime];
    }];
    _projectile addEventHandler ["HitExplosion", {
        PHEN_CS_CSS_LastProjectileImpactState = ["HitExplosion", _this, diag_tickTime];
    }];

    [_projectile, _prediction, _weapon, _muzzle, _mode, _ammo, _magazine] spawn {
        params ["_projectile", "_prediction", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine"];

        private _lastASL = [];
        private _lastVelocity = [];
        private _deadline = diag_tickTime + 8;

        while { !isNull _projectile && { diag_tickTime < _deadline } } do {
            _lastASL = getPosASL _projectile;
            _lastVelocity = velocity _projectile;
            uiSleep 0.05;
        };

        private _predictedASL = if (_prediction isEqualType [] && { (count _prediction) > 0 }) then { _prediction # 0 } else { [] };
        private _impactPosASL = [PHEN_CS_CSS_LastProjectileImpactState] call PHEN_CS_fnc_CSS_getImpactEventPosition;
        private _impactDistanceFromTraceEnd = -1;
        if (_impactPosASL isEqualType [] && { (count _impactPosASL) >= 3 } && { _lastASL isEqualType [] } && { (count _lastASL) >= 3 }) then {
            _impactDistanceFromTraceEnd = _impactPosASL distance _lastASL;
        };

        private _impactEvaluation = [PHEN_CS_CSS_LastProjectileImpactState, _prediction, _lastASL] call PHEN_CS_fnc_CSS_getImpactEvaluation;
        private _predictionErrorUsable = [_impactEvaluation] call PHEN_CS_fnc_CSS_shouldReportPredictionError;
        private _predictionErrorTargetASL = if (_impactPosASL isEqualType [] && { (count _impactPosASL) >= 3 }) then { _impactPosASL } else { _lastASL };
        private _predictionError = -1;
        if (_predictionErrorUsable && { _predictedASL isEqualType [] } && { (count _predictedASL) >= 3 } && { _predictionErrorTargetASL isEqualType [] } && { (count _predictionErrorTargetASL) >= 3 }) then {
            _predictionError = _predictedASL distance _predictionErrorTargetASL;
        };

        ["trace_end", [
            ["weapon", _weapon],
            ["muzzle", _muzzle],
            ["mode", _mode],
            ["magazine", _magazine],
            ["ammo", _ammo],
            ["lastASL", _lastASL],
            ["lastVelocity", _lastVelocity],
            ["prediction", _prediction],
            ["predictionError", _predictionError],
            ["predictionErrorTargetASL", _predictionErrorTargetASL],
            ["impactEvaluation", _impactEvaluation],
            ["predictionErrorUsable", _predictionErrorUsable],
            ["impactPosASL", _impactPosASL],
            ["impactDistanceFromTraceEnd", _impactDistanceFromTraceEnd],
            ["impactState", PHEN_CS_CSS_LastProjectileImpactState]
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

    private _calibrationKey = [_weapon, _muzzle, _mode, _magazine, _ammo, _zeroDistance, stance _unit] call PHEN_CS_fnc_CSS_getShotCalibrationKey;
    private _calibration = [_calibrationKey] call PHEN_CS_fnc_CSS_getShotCalibration;
    _speed = [_speed, _calibration] call PHEN_CS_fnc_CSS_applySpeedCalibration;

    private _applyZeroing = [_unit, _weapon, _muzzle, _mode, _magazine, _ammo] call PHEN_CS_fnc_CSS_shouldApplyZeroing;
    _applyZeroing = [_calibration, _applyZeroing] call PHEN_CS_fnc_CSS_calibrationWantsZeroing;

    private _aimFrame = [_unit, _weapon, _speed, _zeroDistance, _gravityCoef, _applyZeroing] call PHEN_CS_fnc_CSS_getAimFrame;
    if !(_calibration isEqualTo []) then {
        _aimFrame = [_unit, _aimFrame, _calibration] call PHEN_CS_fnc_CSS_applyAimCalibration;
    };
    _aimFrame params ["_startASL", "_sightDir", "_weaponDir", "_viewDir", "_originMethod", "_dirMethod", "_fromWeapon", "_zeroingApplied", "_viewCoherence"];
    if ((vectorMagnitude _sightDir) <= 0.001) exitWith { ["invalid_aim_frame", [_weapon, _weaponDir, _viewDir, _originMethod, _dirMethod]] call PHEN_CS_fnc_CSS_clearAimSolution; };

    private _endASL = _startASL vectorAdd (_sightDir vectorMultiply 5000);
    private _rayHits = lineIntersectsSurfaces [_startASL, _endASL, _unit, vehicle _unit, true, 1, "FIRE", "GEOM", true];
    private _rayHit = if (_rayHits isEqualTo []) then { [] } else { _rayHits # 0 };
    private _rayStatus = [_startASL, _rayHit] call PHEN_CS_fnc_CSS_getAimHitStatus;
    private _rayPosASL = if (_rayStatus # 0) then { _rayHit # 0 } else { [] };

    private _hasACEAdvancedBallistics = isClass (configFile >> "CfgPatches" >> "ace_advanced_ballistics");
    private _label = if (_hasACEAdvancedBallistics) then { "APPROX ACE" } else { "PREDICTED" };
    if (_projectileFamily isEqualTo "rocket") then { _label = "APPROX ROCKET"; };

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

    private _dt = getNumber (_ammoCfg >> "simulationStep");
    if (_dt <= 0) then { _dt = 0.025; };
    _dt = (_dt max 0.01) min 0.05;

    private _dir = _sightDir;
    private _pos = _startASL;
    private _vel = _dir vectorMultiply _speed;
    private _hit = [];
    private _hitReason = "no_intersection";
    private _maxSteps = (ceil (_timeToLive / _dt)) min 900;

    private _i = 0;
    while { _i <= _maxSteps && { _hit isEqualTo [] } && { (_startASL distance _pos) <= 5000 } } do {
        private _elapsed = _i * _dt;
        private _speedNow = vectorMagnitude _vel;
        if (_projectileFamily isEqualTo "rocket") then {
            private _rocketAccelData = [_dir, _vel, _elapsed, _rocketData, _airFriction] call PHEN_CS_fnc_CSS_getRocketAccel;
            _rocketAccelData params ["_rocketAccel", "_rocketMaxSpeed"];
            _vel = _vel vectorAdd (_rocketAccel vectorMultiply _dt);
            if (_rocketMaxSpeed > 0 && { (vectorMagnitude _vel) > _rocketMaxSpeed }) then {
                _vel = (vectorNormalized _vel) vectorMultiply _rocketMaxSpeed;
            };
        } else {
            if (_airFriction != 0 && { _speedNow > 0 }) then {
            private _dragAccel = _vel vectorMultiply (_speedNow * _airFriction);
            _vel = _vel vectorAdd (_dragAccel vectorMultiply _dt);
            };
        };

        _vel = _vel vectorAdd [0,0,(-9.81 * _gravityCoef * _dt)];
        private _next = _pos vectorAdd (_vel vectorMultiply _dt);
        private _segHits = lineIntersectsSurfaces [_pos, _next, _unit, vehicle _unit, true, 1, "FIRE", "GEOM", true];
        if !(_segHits isEqualTo []) then {
            private _hitStatus = [_startASL, _segHits # 0] call PHEN_CS_fnc_CSS_getAimHitStatus;
            if (_hitStatus # 0) then {
                _hitReason = _hitStatus # 1;
                _hit = _segHits # 0;
            } else {
                _hitReason = _hitStatus # 1;
                _pos = _next;
            };
        } else {
            _pos = _next;
        };
        _i = _i + 1;
    };

    if !(_hit isEqualTo []) then {
        if (_projectileFamily isEqualTo "rocket") then {
            private _rocketMethod = "rocket_approx";
            PHEN_CS_CSS_AimSolution = [_hit # 0, diag_tickTime + 0.35, "rocket", _label, _zeroDistance];
            private _payload = [_rocketMethod, _unit, _weapon, _muzzle, _mode, _magazine, _ammo, _simulation, _speed, _airFriction, _gravityCoef, _zeroDistance, _weaponSlot, _aimFrame, _attachmentCoefs, _hitReason, _hit, _predictionQuality] call PHEN_CS_fnc_CSS_getAimDebugPayload;
            [_rocketMethod, _payload] call PHEN_CS_fnc_CSS_setAimDebugState;
        } else {
            PHEN_CS_CSS_AimSolution = [_hit # 0, diag_tickTime + 0.35, "ballistic", _label, _zeroDistance];
            private _payload = ["ballistic_hit", _unit, _weapon, _muzzle, _mode, _magazine, _ammo, _simulation, _speed, _airFriction, _gravityCoef, _zeroDistance, _weaponSlot, _aimFrame, _attachmentCoefs, _hitReason, _hit, _predictionQuality] call PHEN_CS_fnc_CSS_getAimDebugPayload;
            ["ballistic_hit", _payload] call PHEN_CS_fnc_CSS_setAimDebugState;
        };
    } else {
        private _payload = ["no_ballistic_hit", _unit, _weapon, _muzzle, _mode, _magazine, _ammo, _simulation, _speed, _airFriction, _gravityCoef, _zeroDistance, _weaponSlot, _aimFrame, _attachmentCoefs, _hitReason, [["rayStatus", _rayStatus], ["rayHits", _rayHits]], _predictionQuality] call PHEN_CS_fnc_CSS_getAimDebugPayload;
        ["no_ballistic_hit", _payload] call PHEN_CS_fnc_CSS_clearAimSolution;
    };
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
