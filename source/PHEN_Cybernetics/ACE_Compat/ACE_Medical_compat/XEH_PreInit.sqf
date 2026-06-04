// ACE wound handler: scales down incoming damage by the unit's cybernetic damage resistance modifier.
// _this = [_unit, _allDamages, _typeOfDamage, _ammo]. Must return the same 4-element array, or [] to halt the chain.
PHEN_CS_fnc_DmgResistWoundHandler = {
    params ["_unit", "_allDamages", "_typeOfDamage", "_ammo"];
    private _resist = _unit getVariable ["PHEN_CS_damageResistModifier", 0];

    [format ["DmgResist | type=%1, resist=%2, entries=%3", _typeOfDamage, _resist, count _allDamages]] call PHEN_CS_fnc_debugMsg;

    if (_resist <= 0) exitWith {
        ["DmgResist | no resist, passing through"] call PHEN_CS_fnc_debugMsg;
        _this
    };

    {
        private _beforeDmg = _x select 0;
        private _afterDmg = _beforeDmg * (1 - _resist);
        _x set [0, _afterDmg];
        
        [format ["DmgResist | entry %1, part=%2, before=%3, after=%4", _forEachIndex, _x select 1, _beforeDmg, _afterDmg]] call PHEN_CS_fnc_debugMsg;
    } forEach _allDamages;

    ["DmgResist | returning modified _this"] call PHEN_CS_fnc_debugMsg;
    _this
};

// Returns [] to halt the handler chain (no wounds created) when active.
// ACE wound handler: suppresses fall/collision damage while the unit is airborne from a cyber ability.
PHEN_CS_fnc_FallDmgWoundHandler = {
    params ["_unit", "_allDamages", "_typeOfDamage", "_ammo"];
    private _isCyberAirborne = _unit getVariable ["PHEN_CS_IsJumpingOrDashing", false];

    [format ["FallDmg | type=%1, cyberAirborne=%2, entries=%3", _typeOfDamage, _isCyberAirborne, count _allDamages]] call PHEN_CS_fnc_debugMsg;

    if (!_isCyberAirborne) exitWith {
        ["FallDmg | not airborne, passing through"] call PHEN_CS_fnc_debugMsg;
        _this
    };

    private _isFallType = _typeOfDamage in ["falling", "collision", "drowning"];
    if (!_isFallType) exitWith {
        [format ["FallDmg | airborne but type '%1' not suppressed, passing through", _typeOfDamage]] call PHEN_CS_fnc_debugMsg;
        _this
    };

    [format ["FallDmg | SUPPRESSED type=%1, zeroing damage and halting chain", _typeOfDamage]] call PHEN_CS_fnc_debugMsg;
    
    { _x set [0, 0]; } forEach _allDamages;
    []
};