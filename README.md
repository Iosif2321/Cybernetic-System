# Cybernetic System

Публичный репозиторий пакета мода Arma 3 `[FOD] Cybernetics System`.

## Содержимое

- `addons/PHEN_Cybernetics.pbo` - собранный PBO аддон.
- `source/PHEN_Cybernetics/` - распакованное содержимое аддона для проверки и правок.
- `mod.cpp`, `meta.cpp`, `PHEN_CS_icon_*.paa` - метаданные мода и иконки.

## Текущее состояние сборки

В этот публичный пакет включены локализованные CBA-настройки и фильтр списка имплантов Ripperdoc.

Фильтр Ripperdoc можно настраивать через init-поле логики модуля Ripperdoc или через init синхронизированного объекта Ripperdoc.

Фильтр ожидает массив строк. По возможности используйте стабильные внутренние ID киберимплантов. Текущие отображаемые названия тоже принимаются, но ID безопаснее, потому что отображаемые названия могут меняться настройками.

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

Не передавайте classnames экипировки, массивы шлемов или имена переменных без кавычек, если эти переменные уже не содержат валидные строки с ID киберимплантов. Например, этот вариант валиден только если каждый массив `HOV_MK*_helmets` содержит строки, совпадающие с ID киберимплантов или отображаемыми названиями киберимплантов:

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

Дерево `source/PHEN_Cybernetics/` - это распакованное дерево аддона. Сгенерированные файлы `config.cpp` намеренно не включены в опубликованную копию.
