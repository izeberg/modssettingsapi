# CHANGELOG

## 1.6.1

- Updated German localization (CHAMPi)

## 1.6.0

- Added localization support
- Added Belarusian, German, Hungarian, Polish and Ukranian languages support
- Added `onWindowOpened` event to API (Polyacov_Yury)
- Added tooltip support when using Templates API for options controls creation
- Added survival logic for `isDisabledByBattleType` in case when WG changes guiType definitions
- Added mods list sorting by ascending by default by its linkage
- Increased scroll factor for mods list
- Fixed controller naming of `HotkeysController`
- Fixed bug when `StateSwitcher` rendered even when `enabled` key was missing in mod's template
- Fixed scrollbar enforcing when content height is smaller than container height
- Fixed mods list blurriness
- Fixed bug when `ColorChoice` popup would render on right mouse button
- Renamed public API method `checkKeySet` to `checkKeyset` to unify naming style across project
- Silenced warning about missing parent view in view loading logic
- Refactor and cleanup

P.S. To developers who extend `ModsSettingsApi` class to create own settings window instance - please update your code according to changes.
