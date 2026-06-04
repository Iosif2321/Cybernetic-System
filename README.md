# Cybernetic System

Public repository for the Arma 3 `[FOD] Cybernetics System` mod package.

## Contents

- `addons/PHEN_Cybernetics.pbo` - packed addon build.
- `source/PHEN_Cybernetics/` - unpacked addon contents used for inspection and modification.
- `mod.cpp`, `meta.cpp`, `PHEN_CS_icon_*.paa` - mod metadata and icons.

## Current Build Notes

This public package includes the localized CBA settings work and the Ripperdoc implant-list filter.

The Ripperdoc filter can be configured from the init field of the Ripperdoc module logic or from the synced Ripperdoc object.

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

## Signing

The included PBO build is not accompanied by a valid updated `.bisign` file in this repository. The original PHEN private signing key is not present in the available project files.

## Source Notes

The `source/PHEN_Cybernetics/` tree is an unpacked addon tree. Generated `config.cpp` files are intentionally not included in this publication copy.
