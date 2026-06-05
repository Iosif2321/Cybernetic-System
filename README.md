# Cybernetic System

Public repository for the Arma 3 `[FOD] Cybernetics System` mod package.

## Contents

- `addons/PHEN_Cybernetics.pbo` - packed addon build.
- `source/PHEN_Cybernetics/` - unpacked addon contents used for inspection and modification.
- `mod.cpp`, `meta.cpp`, `PHEN_CS_icon_*.paa` - mod metadata and icons.

## Current Build Notes

This public package includes the localized CBA settings work and the Ripperdoc implant-list filter.

The Ripperdoc filter can be configured from the init field of the Ripperdoc module logic or from the synced Ripperdoc object.

The filter expects an array of strings. Use stable internal cybernetic IDs whenever possible. Current display names are also accepted, but IDs are safer because display names can be changed by settings.

Whitelist example:

```sqf
this setVariable ["PHEN_CS_RipperdocAllowedList", [
    "PHEN_CS_Cybernetic_ARMS_ITEM_0",
    "PHEN_CS_Cybernetic_LEGS_ITEM_3"
], true];
```

Blacklist example:

```sqf
this setVariable ["PHEN_CS_RipperdocDeniedList", [
    "PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_2",
    "PHEN_CS_Cybernetic_LEGS_ITEM_7"
], true];
```

Explicit mode example:

```sqf
this setVariable ["PHEN_CS_RipperdocAccessMode", "whitelist", true];
this setVariable ["PHEN_CS_RipperdocAccessList", [
    "PHEN_CS_Cybernetic_ARMS_ITEM_0",
    "PHEN_CS_Cybernetic_LEGS_ITEM_3"
], true];
```

`PHEN_CS_RipperdocAllowedList` enables whitelist behavior. `PHEN_CS_RipperdocDeniedList` enables blacklist behavior. If both are set, the denied list is applied last.

## Ripperdoc Whitelist And Blacklist Rules

Correct input format:

```sqf
[
    "PHEN_CS_Cybernetic_ARMS_ITEM_0",
    "PHEN_CS_Cybernetic_LEGS_ITEM_3"
]
```

Do not pass gear classnames, helmet arrays, or unquoted variable names unless those variables already contain valid cybernetic ID strings. For example, this is only valid if every `HOV_MK*_helmets` array contains strings matching cybernetic IDs or cybernetic display names:

```sqf
private _allowedCybernetics =
    HOV_MK4_helmets
    + HOV_MK5_helmets
    + HOV_MK6_helmets
    + HOV_MK7_helmets;

this setVariable ["PHEN_CS_RipperdocAllowedList", _allowedCybernetics, true];
```

If those arrays contain helmet classnames, the Ripperdoc filter cannot match them to cybernetic implants. Use cybernetic IDs instead.

Avoid putting a long `+` chain directly into a module init field while debugging. Build the list first, then assign it:

```sqf
private _allowedCybernetics = [
    "PHEN_CS_Cybernetic_ARMS_ITEM_0",
    "PHEN_CS_Cybernetic_LEGS_ITEM_3"
];

this setVariable ["PHEN_CS_RipperdocAllowedList", _allowedCybernetics, true];
```

If Arma reports `Error Missing ;` in a settings file, the whitelist script did not finish executing. In that case the Ripperdoc receives no whitelist and falls back to the full implant list.

## Module Init Versus Object Init

Preferred module init:

```sqf
this setVariable ["PHEN_CS_RipperdocAllowedList", [
    "PHEN_CS_Cybernetic_ARMS_ITEM_0",
    "PHEN_CS_Cybernetic_LEGS_ITEM_3"
], true];
```

Object init on the synced Ripperdoc object also works:

```sqf
this setVariable ["PHEN_CS_RipperdocDeniedList", [
    "PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_2"
], true];
```

The module copies its filter settings onto the synced Ripperdoc object when the module initializes, then client-side Ripperdoc actions read the filter from that object.

## Signing

The included PBO build is not accompanied by a valid updated `.bisign` file in this repository. The original PHEN private signing key is not present in the available project files.

## Source Notes

The `source/PHEN_Cybernetics/` tree is an unpacked addon tree. Generated `config.cpp` files are intentionally not included in this publication copy.
