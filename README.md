# Cybernetic System

Публичный репозиторий пакета мода Arma 3 `[FOD] Cybernetics System`.

## Содержимое

- `addons/PHEN_Cybernetics.pbo` - собранный PBO аддона.
- `source/PHEN_Cybernetics/` - распакованное содержимое аддона для проверки и правок.
- `mod.cpp`, `meta.cpp`, `PHEN_CS_icon_*.paa` - метаданные мода и иконки.
- `tests/*.ps1` - статические проверки исходников и поставляемого PBO.

## Текущее состояние сборки

В публичный пакет включены локализованные CBA-настройки, фильтр списка имплантов Ripperdoc и глазной имплант `Argus Combat Optics Mk.IV`.

## Глазной имплант Argus Combat Optics Mk.IV

Имплант находится в категории `OCULAR` и имеет ID:

```sqf
"PHEN_CS_Cybernetic_OCULAR_ITEM_3"
```

Функционал импланта:

- распознавание и 3D-обозначение мин в радиусе 50 метров;
- подсветка союзной пехоты, техники, авиации, БПЛА и стационарных установок до 1000 метров;
- мини-радар видимых союзных контактов с переключаемым масштабом и направлением контактов;
- собственная телеметрия игрока: пульс, давление, кровь, кислород;
- ночное видение и тепловизионный режим через `PHEN_CS_LowLightOptics_MkIV`;
- live-маркер приблизительной точки попадания до выстрела для текущего оружия в руках, включая `primaryWeapon`, `handgunWeapon` и `secondaryWeapon`;
- CBA-настройки размера HUD, 3D-меток союзников и 3D-меток мин для каждого локального игрока отдельно.

## Правила видимости Argus

Контакты ближе 10 метров отображаются по радиусу, без угловой проверки. Это сделано для ближнего сенсорного предупреждения, включая мины.

На дистанции от 10 до 100 метров используется широкий конус обзора 110 градусов. Контакт должен быть в этом конусе и проходить проверку видимости.

Дальше 100 метров используется более строгая проверка: объект должен быть перед камерой, попадать на экран с отступом от краев и проходить `checkVisibility` по `VIEW`.

Мини-радар Argus теперь использует тот же видимый кэш контактов, что и 3D-метки. Он не должен продолжать показывать союзников за спиной, если они уже отфильтрованы системой видимости.

## Маркер точки попадания

Маркер строится до выстрела. Он не читает фактическое место попадания уже выпущенной пули.

Расчет использует:

- `weaponState` текущего юнита;
- текущее оружие, muzzle и магазин;
- `currentZeroing [_weapon, _muzzle]`;
- направление прицеливания от камеры/оптики;
- скорость боеприпаса из `CfgWeapons`, `CfgMagazines` и `CfgAmmo`;
- `airFriction`, `simulationStep` и `coefGravity` из `CfgAmmo`;
- трассировку траектории через `lineIntersectsSurfaces`.

При включенном ACE Advanced Ballistics маркер остается приблизительным и помечается `APPROX ACE`. В коде не используется внутренний undocumented solver ACE. Вместо этого Argus использует свой расчет поверх доступных параметров Arma/ACE config.

## Управление Argus в CBA

Клавиши находятся в категории:

```text
[FOD] Cybernetics System - Tactical HUD
```

Доступные действия:

```text
Cycle Argus Radar Scale
Toggle Argus Digital Zoom
Cycle Argus Digital Zoom Level
```

`Cycle Argus Radar Scale` переключает масштаб мини-радара: 250, 500, 1000 и 2000 метров. Начальный масштаб - 1000 метров.

`Toggle Argus Digital Zoom` включает или выключает состояние цифрового увеличения Argus и его индикацию на HUD.

`Cycle Argus Digital Zoom Level` переключает уровни индикации: x1, x2 и x4.

Argus не добавляет отдельный предмет оптики в руки и не переключает оружие игрока. Штатная фокусировка Arma и оптика оружия остаются на обычных клавишах игрока. CBA-клавиши Argus дают понятное управление состоянием и индикацией глазного HUD, не ломая текущее оружие.

## Масштаб интерфейса Argus

В CBA Addon Options добавлены локальные настройки. Они действуют только для конкретного игрока:

```text
Argus HUD Scale
Argus Allied Marker Scale
Argus Mine Marker Scale
```

`Argus HUD Scale` меняет размер панели Combat Sensor, текста и точек мини-радара.

`Argus Allied Marker Scale` меняет размер 3D-иконок и текста над союзной пехотой, техникой, БПЛА, авиацией и стационарными установками.

`Argus Mine Marker Scale` отдельно меняет размер 3D-иконок и текста мин.

Значение `1.00` сохраняет размер по умолчанию. Настройки локальные, поэтому каждый игрок может подобрать масштаб под свой монитор и интерфейс.

## Пример whitelist Ripperdoc только под Argus

```sqf
this setVariable ["PHEN_CS_RipperdocAllowedList", [
    "PHEN_CS_Cybernetic_OCULAR_ITEM_3"
], true];
```

## Ripperdoc whitelist и blacklist

Фильтр Ripperdoc можно настраивать через init-поле логики модуля Ripperdoc или через init синхронизированного объекта Ripperdoc.

Фильтр ожидает массив строк. По возможности используйте стабильные внутренние ID киберимплантов. Отображаемые названия тоже принимаются, но ID безопаснее, потому что отображаемые названия могут меняться настройками.

Пример whitelist:

```sqf
this setVariable ["PHEN_CS_RipperdocAllowedList", [
    "PHEN_CS_Cybernetic_ARMS_ITEM_0",
    "PHEN_CS_Cybernetic_LEGS_ITEM_3"
], true];
```

Пример blacklist:

```sqf
this setVariable ["PHEN_CS_RipperdocDeniedList", [
    "PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_2",
    "PHEN_CS_Cybernetic_LEGS_ITEM_7"
], true];
```

Пример явного режима:

```sqf
this setVariable ["PHEN_CS_RipperdocAccessMode", "whitelist", true];
this setVariable ["PHEN_CS_RipperdocAccessList", [
    "PHEN_CS_Cybernetic_ARMS_ITEM_0",
    "PHEN_CS_Cybernetic_LEGS_ITEM_3"
], true];
```

`PHEN_CS_RipperdocAllowedList` включает режим whitelist. `PHEN_CS_RipperdocDeniedList` включает режим blacklist. Если заданы оба списка, denied list применяется последним.

## Правила whitelist и blacklist для Ripperdoc

Правильный формат входных данных:

```sqf
[
    "PHEN_CS_Cybernetic_ARMS_ITEM_0",
    "PHEN_CS_Cybernetic_LEGS_ITEM_3"
]
```

Не передавайте classnames экипировки, массивы шлемов или имена переменных без кавычек, если эти переменные уже не содержат валидные строки с ID киберимплантов или отображаемыми названиями киберимплантов.

Например, этот вариант валиден только если каждый массив `HOV_MK*_helmets` содержит строки, совпадающие с ID киберимплантов или отображаемыми названиями:

```sqf
private _allowedCybernetics =
    HOV_MK4_helmets
    + HOV_MK5_helmets
    + HOV_MK6_helmets
    + HOV_MK7_helmets;

this setVariable ["PHEN_CS_RipperdocAllowedList", _allowedCybernetics, true];
```

Если эти массивы содержат classnames шлемов, фильтр Ripperdoc не сможет сопоставить их с киберимплантами. Используйте ID киберимплантов.

Во время отладки не вставляйте длинную цепочку через `+` прямо в init-поле модуля. Сначала соберите список в переменную, затем назначьте его:

```sqf
private _allowedCybernetics = [
    "PHEN_CS_Cybernetic_ARMS_ITEM_0",
    "PHEN_CS_Cybernetic_LEGS_ITEM_3"
];

this setVariable ["PHEN_CS_RipperdocAllowedList", _allowedCybernetics, true];
```

Если Arma показывает `Error Missing ;` в settings-файле, whitelist-скрипт не завершил выполнение. В этом случае Ripperdoc не получает whitelist и возвращается к полному списку имплантов.

## Init модуля и init объекта

Предпочтительный вариант через init модуля:

```sqf
this setVariable ["PHEN_CS_RipperdocAllowedList", [
    "PHEN_CS_Cybernetic_ARMS_ITEM_0",
    "PHEN_CS_Cybernetic_LEGS_ITEM_3"
], true];
```

Init на синхронизированном объекте Ripperdoc тоже работает:

```sqf
this setVariable ["PHEN_CS_RipperdocDeniedList", [
    "PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_2"
], true];
```

При инициализации модуль копирует свои настройки фильтра на синхронизированный объект Ripperdoc. После этого клиентские действия Ripperdoc читают фильтр с этого объекта.

## Подпись

В репозитории нет валидного обновленного `.bisign` файла для включенного PBO. Оригинальный приватный ключ подписи PHEN отсутствует в доступных файлах проекта.

## Примечания по исходникам

Дерево `source/PHEN_Cybernetics/` - это распакованное дерево аддона. Для нового импланта включен текстовый `source/PHEN_Cybernetics/config.cpp`, чтобы изменения класса `PHEN_CS_LowLightOptics_MkIV` можно было проверить без разбора бинарного `config.bin`.
