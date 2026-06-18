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
PHEN_CS_CSS_AimDrawDebugLastLog = 0;
PHEN_CS_CSS_PostShotDebugState = ["init", [], 0];
PHEN_CS_CSS_PostShotDebugLastLog = 0;
PHEN_CS_CSS_LastProjectileImpactState = ["init", [], 0];
PHEN_CS_CSS_ShotSequence = 0;
PHEN_CS_CSS_LastShotContext = [];
PHEN_CS_CSS_AimSolutionTTL = 0.75;
PHEN_CS_CSS_AimDrawSurfaceLift = 0.35;
PHEN_CS_CSS_PIPUpdateMinInterval = 0.35;
PHEN_CS_CSS_PIPNoSolutionRetryInterval = 1.25;
PHEN_CS_CSS_PIPDirDotTolerance = cos 0.2;
PHEN_CS_CSS_PIPNextUpdateAt = 0;
PHEN_CS_CSS_PIPLastKey = "";
PHEN_CS_CSS_PIPLastDir = [0,0,0];
PHEN_CS_CSS_PIPLastSolution = [];
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

PHEN_CS_fnc_CSS_getWindTelemetry = {
    params [["_posASL", []]];

    private _engineWind = wind;
    private _aceWind = [];
    private _aceWindSource = "none";
    private _hasAceWindDeflectionFn = !(isNil "ace_winddeflection_fnc_getCurrentWind");
    private _hasAceWeatherWindFn = !(isNil "ace_weather_fnc_calculateWindSpeed");

    if (_posASL isEqualType [] && { (count _posASL) >= 3 }) then {
        if (_hasAceWindDeflectionFn) then {
            private _windResult = [_posASL] call ace_winddeflection_fnc_getCurrentWind;
            if (_windResult isEqualType [] && { (count _windResult) >= 2 }) then {
                private _windZ = if ((count _windResult) > 2) then { _windResult # 2 } else { 0 };
                _aceWind = [_windResult # 0, _windResult # 1, _windZ];
                _aceWindSource = "ace_winddeflection_fnc_getCurrentWind";
            };
        } else {
            if (_hasAceWeatherWindFn) then {
                private _windMagnitude = [_posASL, true, true, true] call ace_weather_fnc_calculateWindSpeed;
                private _engineWindMagnitude = vectorMagnitude _engineWind;
                _aceWind = if (_engineWindMagnitude > 0.001) then {
                    (vectorNormalized _engineWind) vectorMultiply _windMagnitude
                } else {
                    [0,0,0]
                };
                _aceWindSource = "ace_weather_fnc_calculateWindSpeed";
            };
        };
    };

    [
        ["posASL", _posASL],
        ["engineWind", _engineWind],
        ["engineWindSpeed", vectorMagnitude _engineWind],
        ["aceWind", _aceWind],
        ["aceWindSpeed", if (_aceWind isEqualType [] && { (count _aceWind) >= 3 }) then { vectorMagnitude _aceWind } else { -1 }],
        ["aceWindSource", _aceWindSource],
        ["hasAceWindDeflectionFn", _hasAceWindDeflectionFn],
        ["hasAceWeatherWindFn", _hasAceWeatherWindFn]
    ]
};

PHEN_CS_fnc_CSS_getPIPWindVector = {
    params [["_posASL", []], ["_windTelemetry", []]];

    if (_windTelemetry isEqualTo []) then {
        _windTelemetry = [_posASL] call PHEN_CS_fnc_CSS_getWindTelemetry;
    };

    private _engineWind = [_windTelemetry, "engineWind", wind] call PHEN_CS_fnc_CSS_getPairValue;
    private _aceWind = [_windTelemetry, "aceWind", []] call PHEN_CS_fnc_CSS_getPairValue;
    private _aceWindSource = [_windTelemetry, "aceWindSource", "none"] call PHEN_CS_fnc_CSS_getPairValue;
    private _windVector = _engineWind;

    if (_aceWindSource != "none" && { _aceWind isEqualType [] } && { (count _aceWind) >= 3 }) then {
        _windVector = _aceWind;
    };

    if !(_windVector isEqualType [] && { (count _windVector) >= 3 }) exitWith { [0,0,0] };
    [_windVector # 0, _windVector # 1, _windVector # 2]
};

PHEN_CS_fnc_CSS_getScopeAdjustmentTelemetry = {
    params [["_unit", objNull], ["_weapon", ""], ["_muzzle", ""]];

    private _elevationMil = 0;
    private _windageMil = 0;
    private _source = "none";
    private _raw = [];
    private _hasAceScopesFn = !(isNil "ace_scopes_fnc_getAdjustment");

    if !(isNull _unit) then {
        if (_hasAceScopesFn) then {
            private _adjustmentResult = [_unit, _weapon, _muzzle] call ace_scopes_fnc_getAdjustment;
            _raw = _adjustmentResult;
            if (_adjustmentResult isEqualType [] && { (count _adjustmentResult) >= 2 }) then {
                _elevationMil = _adjustmentResult # 0;
                _windageMil = _adjustmentResult # 1;
                _source = "ace_scopes_fnc_getAdjustment";
            };
        };

        if (_source isEqualTo "none") then {
            private _adjustmentVariable = _unit getVariable ["ace_scopes_adjustment", [[0,0,0],[0,0,0],[0,0,0]]];
            _raw = _adjustmentVariable;
            if (_adjustmentVariable isEqualType [] && { (count _adjustmentVariable) > 0 }) then {
                private _primaryAdjustment = _adjustmentVariable # 0;
                if (_primaryAdjustment isEqualType [] && { (count _primaryAdjustment) >= 2 }) then {
                    _elevationMil = _primaryAdjustment # 0;
                    _windageMil = _primaryAdjustment # 1;
                    _source = "ace_scopes_adjustment";
                };
            };
        };
    };

    [
        ["elevationMil", _elevationMil],
        ["windageMil", _windageMil],
        ["source", _source],
        ["raw", _raw],
        ["hasAceScopesFn", _hasAceScopesFn]
    ]
};

PHEN_CS_fnc_CSS_applyPIPScopeAdjustment = {
    params [["_dir", [0,0,0]], ["_unit", objNull], ["_weapon", ""], ["_muzzle", ""], ["_scopeAdjustmentTelemetry", []]];

    private _baseDir = vectorNormalized _dir;
    if ((vectorMagnitude _baseDir) <= 0.001) exitWith { [_dir, [["applied", false], ["reason", "invalid_direction"]]] };

    if (_scopeAdjustmentTelemetry isEqualTo []) then {
        _scopeAdjustmentTelemetry = [_unit, _weapon, _muzzle] call PHEN_CS_fnc_CSS_getScopeAdjustmentTelemetry;
    };

    private _elevationMil = [_scopeAdjustmentTelemetry, "elevationMil", 0] call PHEN_CS_fnc_CSS_getPairValue;
    private _windageMil = [_scopeAdjustmentTelemetry, "windageMil", 0] call PHEN_CS_fnc_CSS_getPairValue;
    private _source = [_scopeAdjustmentTelemetry, "source", "none"] call PHEN_CS_fnc_CSS_getPairValue;
    private _mil2deg = 0.05729577951308232;
    private _yawDeg = _windageMil * _mil2deg;
    private _pitchDeg = _elevationMil * _mil2deg;

    if (_source isEqualTo "none" || { (abs _yawDeg) < 0.000001 && { (abs _pitchDeg) < 0.000001 } }) exitWith {
        [
            _baseDir,
            [
                ["applied", false],
                ["source", _source],
                ["elevationMil", _elevationMil],
                ["windageMil", _windageMil],
                ["elevationDeg", _pitchDeg],
                ["windageDeg", _yawDeg],
                ["scopeAdjustmentTelemetry", _scopeAdjustmentTelemetry]
            ]
        ]
    };

    private _ref = [0,0,1];
    if (abs (_baseDir vectorDotProduct _ref) > 0.98) then { _ref = [0,1,0]; };
    private _right = vectorNormalized (_baseDir vectorCrossProduct _ref);
    private _up = vectorNormalized (_right vectorCrossProduct _baseDir);
    private _dirYaw = vectorNormalized ((_baseDir vectorMultiply (cos _yawDeg)) vectorAdd (_right vectorMultiply (sin _yawDeg)));
    private _adjustedDir = vectorNormalized ((_dirYaw vectorMultiply (cos _pitchDeg)) vectorAdd (_up vectorMultiply (sin _pitchDeg)));

    [
        _adjustedDir,
        [
            ["applied", true],
            ["source", _source],
            ["elevationMil", _elevationMil],
            ["windageMil", _windageMil],
            ["elevationDeg", _pitchDeg],
            ["windageDeg", _yawDeg],
            ["scopeAdjustmentTelemetry", _scopeAdjustmentTelemetry]
        ]
    ]
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

PHEN_CS_fnc_CSS_isPIP40mmGLProfile = {
    params [["_profile", []], ["_projectileFamily", ""]];

    private _family = toLower _projectileFamily;
    if (_profile isEqualType [] && { !(_profile isEqualTo []) }) then {
        _family = toLower ([_profile, "projectileFamily", _family] call PHEN_CS_fnc_CSS_getPairValue);
    };
    if !(_family isEqualTo "shell") exitWith { false };

    private _magazine = if (_profile isEqualType [] && { !(_profile isEqualTo []) }) then {
        [_profile, "magazine", ""] call PHEN_CS_fnc_CSS_getPairValue
    } else {
        ""
    };

    _magazine in ["1Rnd_HE_Grenade_shell", "3Rnd_HE_Grenade_shell"]
};

PHEN_CS_fnc_CSS_tracePIP40mmGLProfile = {
    params ["_unit", "_aimFrame", "_profile", ["_checkCollision", true]];

    if (isNull _unit || { (count _aimFrame) < 2 }) exitWith { [[], "invalid_aim_frame", [], [], 0, 0, 0, [], ""] };
    if !([_profile, "shell"] call PHEN_CS_fnc_CSS_isPIP40mmGLProfile) exitWith { [[], "unsupported_pip_40mm", [], [], 0, 0, 0, [], ""] };

    _aimFrame params ["_startASL", "_sightDir"];
    if !(_startASL isEqualType [] && { (count _startASL) >= 3 }) exitWith { [[], "invalid_start", [], [], 0, 0, 0, [], ""] };
    if !(_sightDir isEqualType [] && { (count _sightDir) >= 3 } && { (vectorMagnitude _sightDir) > 0.001 }) exitWith { [[], "invalid_direction", [], [], 0, 0, 0, [], ""] };

    private _weapon = [_profile, "weapon", currentWeapon _unit] call PHEN_CS_fnc_CSS_getPairValue;
    private _muzzle = [_profile, "muzzle", currentMuzzle _unit] call PHEN_CS_fnc_CSS_getPairValue;
    private _weaponCfg = configFile >> "CfgWeapons" >> _weapon;
    private _muzzleCfg = if (_muzzle in ["", "this", _weapon]) then { _weaponCfg } else { _weaponCfg >> _muzzle };
    if !(isClass _muzzleCfg) then { _muzzleCfg = _weaponCfg; };

    private _muzzlePos = getText (_muzzleCfg >> "muzzlePos");
    private _muzzleEnd = getText (_muzzleCfg >> "muzzleEnd");
    if (_muzzlePos isEqualTo "" || { _muzzleEnd isEqualTo "" }) then {
        _muzzlePos = getText (_weaponCfg >> "muzzlePos");
        _muzzleEnd = getText (_weaponCfg >> "muzzleEnd");
    };

    private _p0 = _startASL;
    private _dir = vectorNormalized _sightDir;
    if !(_muzzlePos isEqualTo "" || { _muzzleEnd isEqualTo "" }) then {
        private _p0Local = _unit selectionPosition [_muzzlePos, "Memory"];
        private _p1Local = _unit selectionPosition [_muzzleEnd, "Memory"];
        if !(_p0Local isEqualTo [0,0,0] && { _p1Local isEqualTo [0,0,0] }) then {
            private _m0 = _unit modelToWorldWorld _p0Local;
            private _m1 = _unit modelToWorldWorld _p1Local;
            if (_m0 isEqualType [] && { (count _m0) >= 3 } && { _m1 isEqualType [] } && { (count _m1) >= 3 } && { (_m0 distance _m1) > 0.001 }) then {
                _p0 = _m0;
                _dir = vectorNormalized (_m1 vectorAdd (_m0 vectorMultiply -1));
            };
        };
    };

    private _weaponDir = _unit weaponDirection _weapon;
    if (_weaponDir isEqualType [] && { (count _weaponDir) >= 3 } && { (vectorMagnitude _weaponDir) > 0.001 } && { (_weaponDir vectorDotProduct _dir) < 0 }) then {
        _dir = _dir vectorMultiply -1;
    };

    private _scopeTelemetry = [_unit, _weapon, _muzzle] call PHEN_CS_fnc_CSS_getScopeAdjustmentTelemetry;
    private _scopeAdjustment = [_dir, _unit, _weapon, _muzzle, _scopeTelemetry] call PHEN_CS_fnc_CSS_applyPIPScopeAdjustment;
    _dir = _scopeAdjustment # 0;

    private _v0 = 80;
    private _af = -0.001;
    private _gravity = [0,0,-9.81];
    private _dt = 0.025;
    private _maxRange = 1000;
    private _vel = _dir vectorMultiply _v0;
    private _pos = _p0;
    private _hit = [];
    private _hitReason = "no_intersection";
    private _steps = 0;
    private _elapsed = 0;
    private _trajectoryIgnoredHitCount = 0;
    private _trajectoryFirstIgnoredHit = [];
    private _trajectoryIgnoredHitReason = "";

    while { _steps <= 50000 && { _hit isEqualTo [] } && { (_p0 distance _pos) <= _maxRange } } do {
        private _speed = vectorMagnitude _vel;
        private _accel = (_vel vectorMultiply (_af * _speed)) vectorAdd _gravity;
        private _next = _pos vectorAdd (_vel vectorMultiply _dt);
        private _nextVel = _vel vectorAdd (_accel vectorMultiply _dt);
        _elapsed = _elapsed + _dt;

        if ((_p0 distance _next) > _maxRange) then {
            _pos = _next;
            _vel = _nextVel;
            _hitReason = "range_limit";
            _steps = 50001;
        } else {
            if (_checkCollision) then {
                private _segHits = lineIntersectsSurfaces [_pos, _next, _unit, vehicle _unit, true, 3, "FIRE", "GEOM", true];
                _segHits = _segHits select {
                    private _obj = _x # 2;
                    isNull _obj || { !(_obj isKindOf "Bush") && { !(_obj isKindOf "SmallTree") } }
                };
                if !(_segHits isEqualTo []) then {
                    private _hitStatus = [_p0, _segHits # 0, _elapsed, "shell"] call PHEN_CS_fnc_CSS_getTrajectoryHitStatus;
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
                        _vel = _nextVel;
                    };
                } else {
                    _pos = _next;
                    _vel = _nextVel;
                };
            } else {
                _pos = _next;
                _vel = _nextVel;
            };
            _steps = _steps + 1;
        };
    };

    [_hit, _hitReason, _pos, _vel, _steps, _elapsed, _trajectoryIgnoredHitCount, _trajectoryFirstIgnoredHit, _trajectoryIgnoredHitReason]
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

PHEN_CS_fnc_CSS_logAimDebug = {
    params [["_reason", ""], ["_data", []]];

    if !(missionNamespace getVariable ["PHEN_CS_DebugMode", false]) exitWith { false };
    if (diag_tickTime < (PHEN_CS_CSS_AimDebugLastLog + 0.75)) exitWith { false };

    PHEN_CS_CSS_AimDebugLastLog = diag_tickTime;
    diag_log format ["[PHEN_CS][ArgusAim] %1 | %2", _reason, _data];
    false
};

PHEN_CS_fnc_CSS_logAimDrawDebug = {
    params ["_unit", "_impactPosASL", "_drawASL", "_label", "_method"];

    if !(missionNamespace getVariable ["PHEN_CS_DebugMode", false]) exitWith { false };
    if (diag_tickTime < (PHEN_CS_CSS_AimDrawDebugLastLog + 0.75)) exitWith { false };

    PHEN_CS_CSS_AimDrawDebugLastLog = diag_tickTime;
    private _validImpact = _impactPosASL isEqualType [] && { (count _impactPosASL) >= 3 };
    private _validDraw = _drawASL isEqualType [] && { (count _drawASL) >= 3 };
    private _drawDeltaASL = if (_validImpact && { _validDraw }) then { _drawASL vectorAdd (_impactPosASL vectorMultiply -1) } else { [] };
    private _drawDeltaDistance = if (_validImpact && { _validDraw }) then { _impactPosASL distance _drawASL } else { -1 };
    private _drawAGL = if (_validDraw) then { ASLToAGL _drawASL } else { [] };
    private _screen = if (_validDraw) then { worldToScreen _drawAGL } else { [] };

    diag_log format ["[PHEN_CS][ArgusAimDraw] draw | %1", [
        ["predictedImpactASL", _impactPosASL],
        ["drawASL", _drawASL],
        ["drawAGL", _drawAGL],
        ["drawDeltaASL", _drawDeltaASL],
        ["drawDeltaDistance", _drawDeltaDistance],
        ["screen", _screen],
        ["label", _label],
        ["method", _method]
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
    params [["_reason", ""], ["_data", []]];

    PHEN_CS_CSS_AimSolution = [];
    [_reason, _data] call PHEN_CS_fnc_CSS_setAimDebugState;
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
    false
};

PHEN_CS_fnc_CSS_logPostShotImpactDebug = {
    params [["_reason", ""], ["_data", []]];

    private _shotId = [_data, "shotId", ""] call PHEN_CS_fnc_CSS_getPairValue;
    private _prediction = [_data, "prediction", []] call PHEN_CS_fnc_CSS_getPairValue;
    private _predictionZeroDistance = -1;
    if (_prediction isEqualType [] && { (count _prediction) > 4 }) then {
        _predictionZeroDistance = _prediction # 4;
    };
    private _zeroDistance = [_data, "zeroDistance", _predictionZeroDistance] call PHEN_CS_fnc_CSS_getPairValue;
    private _impactEvaluation = [_data, "impactEvaluation", []] call PHEN_CS_fnc_CSS_getPairValue;
    private _impactState = [_data, "impactState", []] call PHEN_CS_fnc_CSS_getPairValue;
    private _impactStateShotId = if (_impactState isEqualType [] && { (count _impactState) > 3 }) then { _impactState # 3 } else { "" };

    [_reason, [
        ["shotId", _shotId],
        ["weapon", [_data, "weapon", ""] call PHEN_CS_fnc_CSS_getPairValue],
        ["mode", [_data, "mode", ""] call PHEN_CS_fnc_CSS_getPairValue],
        ["ammo", [_data, "ammo", ""] call PHEN_CS_fnc_CSS_getPairValue],
        ["zeroDistance", _zeroDistance],
        ["predictedImpactASL", [_data, "predictedImpactASL", []] call PHEN_CS_fnc_CSS_getPairValue],
        ["postShotImpactPointASL", [_data, "postShotImpactPointASL", []] call PHEN_CS_fnc_CSS_getPairValue],
        ["predictionError", [_data, "predictionError", -1] call PHEN_CS_fnc_CSS_getPairValue],
        ["predictionErrorVectorASL", [_data, "predictionErrorVectorASL", []] call PHEN_CS_fnc_CSS_getPairValue],
        ["predictionErrorUsable", [_data, "predictionErrorUsable", false] call PHEN_CS_fnc_CSS_getPairValue],
        ["impactKind", [_impactEvaluation, "impactKind", ""] call PHEN_CS_fnc_CSS_getPairValue],
        ["impactReason", [_impactEvaluation, "reason", ""] call PHEN_CS_fnc_CSS_getPairValue],
        ["impactScoreable", [_impactEvaluation, "scoreable", false] call PHEN_CS_fnc_CSS_getPairValue],
        ["impactUsable", [_impactEvaluation, "usable", false] call PHEN_CS_fnc_CSS_getPairValue],
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
    private _prediction = +PHEN_CS_CSS_AimSolution;
    private _predictionMeta = [_prediction] call PHEN_CS_fnc_CSS_getAimSolutionMeta;
    private _predictedImpactASL = if (_prediction isEqualType [] && { (count _prediction) > 0 }) then { _prediction # 0 } else { [] };
    private _projectileStartASL = if (isNull _projectile) then { [] } else { getPosASL _projectile };
    private _projectileVelocity = if (isNull _projectile) then { [] } else { velocity _projectile };
    private _shotInfo = if (isNull _projectile) then { [] } else { getShotInfo _projectile };
    private _zeroing = _unit currentZeroing [_weapon, _muzzle];
    private _zeroDistance = [_zeroing] call PHEN_CS_fnc_CSS_getZeroDistance;
    private _solutionMethod = if (_prediction isEqualType [] && { (count _prediction) > 2 }) then { _prediction # 2 } else { "" };
    private _solutionLabel = if (_prediction isEqualType [] && { (count _prediction) > 3 }) then { _prediction # 3 } else { "" };

    private _shotContext = [
        ["shotId", _shotId],
        ["shotTickTime", _shotTickTime],
        ["shotFrameNo", _shotFrameNo],
        ["weapon", _weapon],
        ["muzzle", _muzzle],
        ["mode", _mode],
        ["magazine", _magazine],
        ["ammo", _ammo],
        ["unitPosASL", getPosASL _unit],
        ["eyePosASL", eyePos _unit],
        ["eyeDirection", eyeDirection _unit],
        ["weaponDirection", _unit weaponDirection _weapon],
        ["projectileStartASL", _projectileStartASL],
        ["projectileVelocity", _projectileVelocity],
        ["firedFrame0ASL", _projectileStartASL],
        ["firedFrame0Velocity", _projectileVelocity],
        ["shotInfo", _shotInfo],
        ["zeroing", _zeroing],
        ["zeroDistance", _zeroDistance],
        ["predictedImpactASL", _predictedImpactASL],
        ["solutionMethod", _solutionMethod],
        ["solutionLabel", _solutionLabel],
        ["predictionMeta", _predictionMeta],
        ["prediction", _prediction]
    ];

    PHEN_CS_CSS_LastShotContext = [_shotId, _shotContext, diag_tickTime];
    PHEN_CS_CSS_LastProjectileImpactState = ["fired", [], diag_tickTime, _shotId];
    ["fired", _shotContext] call PHEN_CS_fnc_CSS_logShotContext;
    ["fired", _shotContext] call PHEN_CS_fnc_CSS_logShotAim;
    ["fired", _shotContext] call PHEN_CS_fnc_CSS_setPostShotDebugState;
    ["fired", _shotContext] call PHEN_CS_fnc_CSS_logShotPrediction;

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

    [_shotId, _shotTickTime, _shotFrameNo, _projectile, _prediction, _weapon, _muzzle, _mode, _ammo, _magazine] spawn {
        params ["_shotId", "_shotTickTime", "_shotFrameNo", "_projectile", "_prediction", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine"];

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
                ["posASL", _lastASL],
                ["velocity", _lastVelocity]
            ]] call PHEN_CS_fnc_CSS_logShotTraceFrame;
            _frame = _frame + 1;
            uiSleep 0;
        };

        private _predictedASL = if (_prediction isEqualType [] && { (count _prediction) > 0 }) then { _prediction # 0 } else { [] };
        private _predictionMeta = [_prediction] call PHEN_CS_fnc_CSS_getAimSolutionMeta;
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
        private _predictionErrorVectorASL = [];
        if (_predictionErrorUsable && { _predictedASL isEqualType [] } && { (count _predictedASL) >= 3 } && { _predictionErrorTargetASL isEqualType [] } && { (count _predictionErrorTargetASL) >= 3 }) then {
            _predictionErrorVectorASL = _predictionErrorTargetASL vectorAdd (_predictedASL vectorMultiply -1);
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
            ["firedFrame0ASL", _firedFrame0ASL],
            ["firedFrame0Velocity", _firedFrame0Velocity],
            ["lastASL", _lastASL],
            ["lastVelocity", _lastVelocity],
            ["prediction", _prediction],
            ["predictionMeta", _predictionMeta],
            ["predictedImpactASL", _predictedASL],
            ["postShotImpactPointASL", _predictionErrorTargetASL],
            ["predictionError", _predictionError],
            ["predictionErrorTargetASL", _predictionErrorTargetASL],
            ["predictionErrorVectorASL", _predictionErrorVectorASL],
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

PHEN_CS_fnc_CSS_getPIPImpactSolution = {
    params [["_unit", objNull]];

    if (isNull _unit || { !alive _unit }) exitWith { [false, [], "invalid_unit", "NO SOLUTION", 0, []] };

    private _state = weaponState _unit;
    _state params ["_weapon", "_muzzle", "_mode", "_magazine", "_ammoCount"];
    if (_weapon isEqualTo "") then { _weapon = currentWeapon _unit; };
    if (_muzzle isEqualTo "") then { _muzzle = currentMuzzle _unit; };
    if (_magazine isEqualTo "") then { _magazine = currentMagazine _unit; };
    if (_weapon isEqualTo "" || { _magazine isEqualTo "" } || { _ammoCount <= 0 }) exitWith { [false, [], "empty_weapon", "NO SOLUTION", 0, [["weapon", _weapon], ["muzzle", _muzzle], ["magazine", _magazine], ["ammoCount", _ammoCount]]] };

    private _magCfg = configFile >> "CfgMagazines" >> _magazine;
    private _ammo = getText (_magCfg >> "ammo");
    private _ammoCfg = configFile >> "CfgAmmo" >> _ammo;
    if (_ammo isEqualTo "" || { !(isClass _ammoCfg) }) exitWith { [false, [], "missing_ammo_config", "NO SOLUTION", 0, [["weapon", _weapon], ["muzzle", _muzzle], ["magazine", _magazine], ["ammo", _ammo]]] };

    private _zeroing = _unit currentZeroing [_weapon, _muzzle];
    private _zeroDistance = [_zeroing] call PHEN_CS_fnc_CSS_getZeroDistance;
    private _simulation = toLower (getText (_ammoCfg >> "simulation"));
    private _isBullet = _ammo isKindOf ["BulletBase", configFile >> "CfgAmmo"];
    private _isRocket = _ammo isKindOf ["RocketBase", configFile >> "CfgAmmo"];
    private _isMissile = _ammo isKindOf ["MissileBase", configFile >> "CfgAmmo"];
    private _isPIP40mm = _magazine in ["1Rnd_HE_Grenade_shell", "3Rnd_HE_Grenade_shell"];
    private _pipACEAvailable = !(isNil "PIP_fnc_accelACE");
    private _pipHitAvailable = !(isNil "PIP_fnc_firstValidHit");

    if (_isRocket || { _isMissile } || { (toLower _ammo) find "pellets" >= 0 }) exitWith {
        [false, [], "pip_unsupported_projectile", "NO SOLUTION", _zeroDistance, [["weapon", _weapon], ["muzzle", _muzzle], ["magazine", _magazine], ["ammo", _ammo], ["simulation", _simulation]]]
    };

    private _dirForThrottle = _unit weaponDirection _weapon;
    if !(_dirForThrottle isEqualType [] && { (count _dirForThrottle) >= 3 } && { (vectorMagnitude _dirForThrottle) > 0.001 }) then {
        _dirForThrottle = [_unit] call PHEN_CS_fnc_CSS_getViewDirection;
    };
    _dirForThrottle = vectorNormalized _dirForThrottle;
    private _pipKey = format ["%1|%2|%3|%4|%5|%6", _weapon, _muzzle, _mode, _magazine, _ammo, round _zeroDistance];
    private _now = diag_tickTime;
    private _sameKey = _pipKey isEqualTo PHEN_CS_CSS_PIPLastKey;
    private _lastDirValid = PHEN_CS_CSS_PIPLastDir isEqualType [] && { (count PHEN_CS_CSS_PIPLastDir) >= 3 } && { (vectorMagnitude PHEN_CS_CSS_PIPLastDir) > 0.001 };
    private _sameDir = _lastDirValid && { (_dirForThrottle vectorDotProduct PHEN_CS_CSS_PIPLastDir) >= PHEN_CS_CSS_PIPDirDotTolerance };
    if (_sameKey && { _sameDir } && { _now < PHEN_CS_CSS_PIPNextUpdateAt }) exitWith {
        if (PHEN_CS_CSS_PIPLastSolution isEqualType [] && { (count PHEN_CS_CSS_PIPLastSolution) >= 6 }) then {
            +PHEN_CS_CSS_PIPLastSolution
        } else {
            [false, [], "pip_retry_backoff", "NO SOLUTION", _zeroDistance, [["weapon", _weapon], ["muzzle", _muzzle], ["magazine", _magazine], ["ammo", _ammo], ["nextUpdateAt", PHEN_CS_CSS_PIPNextUpdateAt]]]
        }
    };

    PHEN_CS_CSS_PIPLastKey = _pipKey;
    PHEN_CS_CSS_PIPLastDir = _dirForThrottle;

    if (_isPIP40mm) exitWith {
        private _profile = [
            ["weapon", _weapon],
            ["muzzle", _muzzle],
            ["mode", _mode],
            ["magazine", _magazine],
            ["ammo", _ammo],
            ["ammoCfg", _ammoCfg],
            ["projectileFamily", "shell"]
        ];
        private _dir = _unit weaponDirection _weapon;
        if !(_dir isEqualType [] && { (count _dir) >= 3 } && { (vectorMagnitude _dir) > 0.001 }) then {
            _dir = [_unit] call PHEN_CS_fnc_CSS_getViewDirection;
        };
        private _trace = [_unit, [eyePos _unit, _dir], _profile, true] call PHEN_CS_fnc_CSS_tracePIP40mmGLProfile;
        _trace params ["_hit", "_hitReason", "_traceEndASL", "_traceEndVelocity", "_traceSteps", "_traceTimeOfFlight", "_ignoredHitCount", "_firstIgnoredHit", "_ignoredHitReason"];
        private _impactASL = if !(_hit isEqualTo []) then { _hit # 0 } else { [] };
        if !(_impactASL isEqualType [] && { (count _impactASL) >= 3 }) exitWith {
            PHEN_CS_CSS_PIPLastSolution = [];
            PHEN_CS_CSS_PIPNextUpdateAt = diag_tickTime + PHEN_CS_CSS_PIPNoSolutionRetryInterval;
            [false, [], "pip_40mm_no_hit", "PIP 40MM", _zeroDistance, [["weapon", _weapon], ["muzzle", _muzzle], ["magazine", _magazine], ["ammo", _ammo], ["hitReason", _hitReason], ["traceEndASL", _traceEndASL], ["traceSteps", _traceSteps], ["traceTimeOfFlight", _traceTimeOfFlight], ["trajectoryIgnoredHitCount", _ignoredHitCount], ["trajectoryFirstIgnoredHit", _firstIgnoredHit], ["trajectoryIgnoredHitReason", _ignoredHitReason]]]
        };
        private _solution = [true, _impactASL, "pip_40mm", "PIP 40MM", _zeroDistance, [["source", "PIPI_EBW_40mm"], ["weapon", _weapon], ["muzzle", _muzzle], ["magazine", _magazine], ["ammo", _ammo], ["hitReason", _hitReason], ["traceEndASL", _traceEndASL], ["traceEndVelocity", _traceEndVelocity], ["traceSteps", _traceSteps], ["traceTimeOfFlight", _traceTimeOfFlight], ["trajectoryIgnoredHitCount", _ignoredHitCount], ["trajectoryFirstIgnoredHit", _firstIgnoredHit], ["trajectoryIgnoredHitReason", _ignoredHitReason]]];
        PHEN_CS_CSS_PIPLastSolution = +_solution;
        PHEN_CS_CSS_PIPNextUpdateAt = diag_tickTime + PHEN_CS_CSS_PIPUpdateMinInterval;
        _solution
    };

    if (!_isBullet) exitWith {
        [false, [], "pip_unsupported_nonbullet", "NO SOLUTION", _zeroDistance, [["weapon", _weapon], ["muzzle", _muzzle], ["magazine", _magazine], ["ammo", _ammo], ["simulation", _simulation]]]
    };

    if (isNil "PIP_fnc_updatePath" || { isNil "PIP_fnc_proxyP0Dir" } || { isNil "PIP_fnc_refreshProxyCache" } || { !_pipHitAvailable }) exitWith {
        PHEN_CS_CSS_PIPLastSolution = [];
        PHEN_CS_CSS_PIPNextUpdateAt = diag_tickTime + PHEN_CS_CSS_PIPNoSolutionRetryInterval;
        [false, [], "pip_ebw_missing", "NO SOLUTION", _zeroDistance, [["required", ["PIP_fnc_updatePath", "PIP_fnc_proxyP0Dir", "PIP_fnc_refreshProxyCache", "PIP_fnc_firstValidHit"]], ["pipACEAvailable", _pipACEAvailable]]]
    };

    if (isNil "PIP_useACE_AB") then { PIP_useACE_AB = false; };
    if (isNil "PIP_params") then { PIP_params = [-1,0,100,"",0.005,1]; };
    if (isNil "PIP_paramsACE") then { PIP_paramsACE = []; };
    if (isNil "PIP_mvTable") then { PIP_mvTable = createHashMap; };
    if (isNil "PIP_deltaCache") then { PIP_deltaCache = createHashMap; };
    if (isNil "PIP_deltaCacheACE") then { PIP_deltaCacheACE = createHashMap; };
    if (isNil "PIP_cached_enableACE") then { PIP_cached_enableACE = true; };
    if (isNil "PIP_cached_retardCoefACE") then { PIP_cached_retardCoefACE = 1.0; };
    if (isNil "PIP_cached_windScaleACE") then { PIP_cached_windScaleACE = 1.0; };
    if (isNil "PIP_cached_crossWindScaleACE") then { PIP_cached_crossWindScaleACE = 1.0; };
    if (isNil "PIP_cached_enableSpinDrift") then { PIP_cached_enableSpinDrift = true; };
    if (isNil "PIP_cached_spinDriftScale") then { PIP_cached_spinDriftScale = 1.0; };
    if (isNil "PIP_cached_enableCoriolis") then { PIP_cached_enableCoriolis = true; };
    if (isNil "PIP_cached_coriolisScale") then { PIP_cached_coriolisScale = 1.0; };
    if (isNil "PIP_cached_afManualCoef") then { PIP_cached_afManualCoef = 1.0; };
    if (isNil "PIP_cached_maxSeg") then { PIP_cached_maxSeg = 3000; };
    if (isNil "PIP_cached_maxRange") then { PIP_cached_maxRange = 2000; };
    if (isNil "PIP_cached_penetrateVegetation") then { PIP_cached_penetrateVegetation = true; };
    if (isNil "PIP_segSpacingMin") then { PIP_segSpacingMin = 2.5; };

    PIP_cached_enableACE = missionNamespace getVariable ["PIP_enableACE_Mode", true];
    PIP_cached_retardCoefACE = missionNamespace getVariable ["PIP_retardCoefACE", 1.0];
    PIP_cached_windScaleACE = missionNamespace getVariable ["PIP_windScaleACE", 1.0];
    PIP_cached_crossWindScaleACE = missionNamespace getVariable ["PIP_crossWindScaleACE", 1.0];
    PIP_cached_enableSpinDrift = missionNamespace getVariable ["PIP_enableSpinDrift", true];
    PIP_cached_spinDriftScale = missionNamespace getVariable ["PIP_spinDriftScale", 1.0];
    PIP_cached_enableCoriolis = missionNamespace getVariable ["PIP_enableCoriolis", true];
    PIP_cached_coriolisScale = missionNamespace getVariable ["PIP_coriolisScale", 1.0];
    PIP_cached_afManualCoef = missionNamespace getVariable ["PIP_afManualCoef", 1.0];
    PIP_cached_maxSeg = missionNamespace getVariable ["PIP_maxSeg", 3000];
    PIP_cached_maxRange = missionNamespace getVariable ["PIP_maxRange", 2000];
    PIP_cached_penetrateVegetation = missionNamespace getVariable ["PIP_penetrateVegetation", true];
    if !(isNil "PIP_fnc_getLatitudeDeg") then { PIP_latDeg = call PIP_fnc_getLatitudeDeg; };

    [_unit] call PIP_fnc_refreshProxyCache;

    private _cfgW = configFile >> "CfgWeapons" >> _weapon;
    private _cfgM = if (_muzzle in ["", "this", _weapon]) then { _cfgW } else { _cfgW >> _muzzle };
    if !(isClass _cfgM) then { _cfgM = _cfgW; };
    private _magInit = getNumber (_magCfg >> "initSpeed");
    private _ammoInit = getNumber (_ammoCfg >> "initSpeed");
    private _ammoTyp = getNumber (_ammoCfg >> "typicalSpeed");
    private _base = if (_magInit > 0) then { _magInit } else { if (_ammoInit > 0) then { _ammoInit } else { _ammoTyp } };
    private _v0Cfg = _base max 0.1;
    private _weaponInit = getNumber (_cfgM >> "initSpeed");
    if (_weaponInit == 0) then { _weaponInit = getNumber (_cfgW >> "initSpeed"); };
    if (_weaponInit > 0) then { _v0Cfg = _weaponInit; } else { if (_weaponInit < 0) then { _v0Cfg = _v0Cfg * abs _weaponInit; }; };
    private _silencer = (_unit weaponAccessories _muzzle) param [0, ""];
    private _coefSilencer = 1;
    if !(_silencer isEqualTo "") then {
        private _cfgSilencer = configFile >> "CfgWeapons" >> _silencer;
        private _coef = getNumber (_cfgSilencer >> "ItemInfo" >> "MagazineCoef" >> "initSpeed");
        if (_coef > 0) then { _coefSilencer = _coef; };
    };
    private _v0Final = (_v0Cfg * _coefSilencer) max 0.1;
    private _airFriction = getNumber (_ammoCfg >> "airFriction");
    private _dt = getNumber (_ammoCfg >> "simulationStep");
    if (_dt <= 0) then { _dt = 0.005; };
    private _coefG = getNumber (_ammoCfg >> "coefGravity");
    if (_coefG <= 0) then { _coefG = 1; };
    PIP_params = [_v0Final, _airFriction * PIP_cached_afManualCoef, _zeroDistance, _ammo, _dt, _coefG];
    missionNamespace setVariable ["PIP_zeroM", _zeroDistance];

    private _boreHeight = 0;
    if !(isNil "ace_scopes_fnc_getBoreHeight") then {
        private _optic = (_unit weaponAccessories _muzzle) param [0, ""];
        {
            private _tryHeight = [_unit, _x, _optic] call ace_scopes_fnc_getBoreHeight;
            if (_tryHeight > 0) exitWith { _boreHeight = _tryHeight; };
        } forEach [0,1,2];
    };
    missionNamespace setVariable ["PIP_boreH_m", _boreHeight];

    PIP_useACE_AB = if !(isNil "PIP_fnc_isACEABEnabled") then { call PIP_fnc_isACEABEnabled } else { false };
    PIP_paramsACE = [];
    if (PIP_useACE_AB && { _pipACEAvailable } && { _isBullet } && { !(isNil "ace_advanced_ballistics_fnc_readAmmoDataFromConfig") } && { !(isNil "ace_advanced_ballistics_fnc_readWeaponDataFromConfig") }) then {
        private _ammoEntry = _ammo call ace_advanced_ballistics_fnc_readAmmoDataFromConfig;
        private _weaponEntry = _weapon call ace_advanced_ballistics_fnc_readWeaponDataFromConfig;
        if (_ammoEntry isEqualType [] && { (count _ammoEntry) > 0 } && { _weaponEntry isEqualType [] } && { (count _weaponEntry) > 0 }) then {
            _ammoEntry params ["_airFricAB", "_cal", "_bLen", "_bMass", "_transCoef", "_dragModel", "_bcs", "_vBounds", "_atmoModel", "_ammoTempShiftTbl", "_mvTableACE", "_barLenTbl", "_mvVarSD"];
            _weaponEntry params ["_twist", "_twistDir", "_barLen"];
            if (isNil "_transCoef") then { _transCoef = 0.5; };

            private _altASL = (getPosASL _unit) # 2;
            private _v0ACE = _v0Final;
            if (missionNamespace getVariable ["ace_advanced_ballistics_barrelLengthInfluenceEnabled", false]) then {
                _v0ACE = _v0ACE + ([_barLen, _mvTableACE, _barLenTbl, _v0ACE] call ace_advanced_ballistics_fnc_calculateBarrelLengthVelocityShift);
            };
            if (missionNamespace getVariable ["ace_advanced_ballistics_ammoTemperatureEnabled", false] && { !(isNil "ace_weather_fnc_calculateTemperatureAtHeight") }) then {
                private _tempForShift = _altASL call ace_weather_fnc_calculateTemperatureAtHeight;
                _v0ACE = _v0ACE + ([_ammoTempShiftTbl, _tempForShift] call ace_advanced_ballistics_fnc_calculateAmmoTemperatureVelocityShift);
            };

            private _tempC = if !(isNil "ace_weather_fnc_calculateTemperatureAtHeight") then { _altASL call ace_weather_fnc_calculateTemperatureAtHeight } else { 15 };
            private _pressHpa = if !(isNil "ace_weather_fnc_calculateBarometricPressure") then { _altASL call ace_weather_fnc_calculateBarometricPressure } else { 1013 };
            private _rh = missionNamespace getVariable ["ace_weather_currentHumidity", 0.5];
            if (_rh > 1) then { _rh = _rh / 100; };
            _rh = (_rh max 0) min 1;
            private _atmo = if (_atmoModel isEqualTo "") then { "ICAO" } else { _atmoModel };
            private _stab = if !(isNil "ace_advanced_ballistics_fnc_calculateStabilityFactor") then {
                [_cal, _bLen, _bMass, _twist, _v0ACE, _tempC, _pressHpa] call ace_advanced_ballistics_fnc_calculateStabilityFactor
            } else {
                1
            };
            PIP_paramsACE = [_v0ACE max 0.1, _dragModel, _bcs, _vBounds, _atmo, _tempC, _pressHpa, _rh, _twistDir, _stab, _transCoef];
        };
    };
    if (PIP_useACE_AB && { PIP_paramsACE isEqualTo [] }) then { PIP_useACE_AB = false; };

    PIP_cache_valid = false;
    [_unit] call PIP_fnc_updatePath;

    if !(missionNamespace getVariable ["PIP_cache_valid", false]) exitWith {
        PHEN_CS_CSS_PIPLastSolution = [];
        PHEN_CS_CSS_PIPNextUpdateAt = diag_tickTime + PHEN_CS_CSS_PIPNoSolutionRetryInterval;
        [false, [], "pip_ebw_no_solution", "PIP", _zeroDistance, [["weapon", _weapon], ["muzzle", _muzzle], ["magazine", _magazine], ["ammo", _ammo], ["pipUseACE", PIP_useACE_AB], ["pipParamsACEReady", !(PIP_paramsACE isEqualTo [])]]]
    };

    private _impactLocal = missionNamespace getVariable ["PIP_cache_impactLocal", []];
    private _p0d = [_unit] call PIP_fnc_proxyP0Dir;
    if !(_impactLocal isEqualType [] && { (count _impactLocal) >= 3 } && { _p0d isEqualType [] } && { (count _p0d) >= 2 }) exitWith {
        [false, [], "pip_ebw_invalid_result", "PIP", _zeroDistance, [["weapon", _weapon], ["muzzle", _muzzle], ["magazine", _magazine], ["ammo", _ammo], ["impactLocal", _impactLocal], ["p0d", _p0d]]]
    };

    private _p0 = _p0d # 0;
    private _dir = vectorNormalized (_p0d # 1);
    private _ref = [0,0,1];
    if (abs (_dir vectorDotProduct _ref) > 0.98) then { _ref = [0,1,0]; };
    private _right = vectorNormalized (_dir vectorCrossProduct _ref);
    private _up = vectorNormalized (_right vectorCrossProduct _dir);
    private _impactASL = _p0 vectorAdd ((_dir vectorMultiply (_impactLocal # 0)) vectorAdd ((_right vectorMultiply (_impactLocal # 1)) vectorAdd (_up vectorMultiply (_impactLocal # 2))));
    private _method = if (PIP_useACE_AB && { !(PIP_paramsACE isEqualTo []) }) then { "pip_ace" } else { "pip_ebw" };
    private _label = if (_method isEqualTo "pip_ace") then { "PIP ACE" } else { "PIP EBW" };
    private _solution = [true, _impactASL, _method, _label, _zeroDistance, [["source", "PIPI_2_EBW"], ["weapon", _weapon], ["muzzle", _muzzle], ["mode", _mode], ["magazine", _magazine], ["ammo", _ammo], ["zeroDistance", _zeroDistance], ["pipUseACE", PIP_useACE_AB], ["pipParams", PIP_params], ["pipParamsACEReady", !(PIP_paramsACE isEqualTo [])], ["pipImpactLocal", _impactLocal], ["pipTOF", missionNamespace getVariable ["PIP_lastTOF", -1]], ["pipHoldMil", missionNamespace getVariable ["PIP_holdMil", 0]], ["pipACEAvailable", _pipACEAvailable], ["pipFirstValidHitAvailable", _pipHitAvailable]]];
    PHEN_CS_CSS_PIPLastSolution = +_solution;
    PHEN_CS_CSS_PIPNextUpdateAt = diag_tickTime + PHEN_CS_CSS_PIPUpdateMinInterval;
    _solution
};

PHEN_CS_fnc_CSS_updateAimPrediction = {
    if !(call PHEN_CS_fnc_CSS_hasSuite) exitWith { ["no_suite", []] call PHEN_CS_fnc_CSS_clearAimSolution; };

    private _unit = call PHEN_CS_fnc_CSS_getUnit;
    if (isNull _unit || { !alive _unit }) exitWith { ["invalid_unit", []] call PHEN_CS_fnc_CSS_clearAimSolution; };
    if !(isNull (objectParent _unit)) exitWith { ["in_vehicle", []] call PHEN_CS_fnc_CSS_clearAimSolution; };

    private _solution = [_unit] call PHEN_CS_fnc_CSS_getPIPImpactSolution;
    _solution params ["_ok", "_impactASL", "_method", "_label", "_zeroDistance", "_meta"];

    if (!_ok || { !(_impactASL isEqualType []) } || { (count _impactASL) < 3 }) exitWith {
        [_method, _meta] call PHEN_CS_fnc_CSS_clearAimSolution;
    };

    PHEN_CS_CSS_AimSolution = [_impactASL, diag_tickTime + PHEN_CS_CSS_AimSolutionTTL, _method, _label, _zeroDistance, _meta];
    [_method, [
        ["impactASL", _impactASL],
        ["method", _method],
        ["label", _label],
        ["zeroDistance", _zeroDistance],
        ["source", "pip_only"],
        ["meta", _meta]
    ]] call PHEN_CS_fnc_CSS_setAimDebugState;
};

PHEN_CS_fnc_CSS_getAimDrawASL = {
    params ["_unit", "_impactPosASL"];

    if (isNull _unit || { !(_impactPosASL isEqualType []) } || { (count _impactPosASL) < 3 }) exitWith { [] };
    +_impactPosASL
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
            [_unit, _impactPosASL, _drawASL, _label, _method] call PHEN_CS_fnc_CSS_logAimDrawDebug;
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
