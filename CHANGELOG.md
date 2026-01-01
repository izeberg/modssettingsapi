# CHANGELOG

### 1.7.0
- Added new component: StepSlider (same as graphics settings sliders)
- Added ability to modify height for the Empty component to create bottom margins to precisely tweak component positions, especially when both columns are used
- Added ability to change tooltip icon types (i.e., info, attention, etc.)
- Fixed very rare scrollPane dispose errors in logs
- Fixed valueLabel htmlText breaking on value update

### 1.6.4
- Fixed `AttributeError` for the renamed `wg_getPreferencesFilePath` method for MT

### 1.6.3
- Fixed `ImportError` when trying to import dependency manager on Lesta client since 1.34
- Fixed deprecated `checkKeySet` call log spam

### 1.6.2
- Added smooth scrolling to the window content (credits: poliroid)
- Fixed window resizing handling when interface scale changed
- Fixed floating point precision issue in slider
- Cleanup

### 1.6.1
- Fixed issue where the `enabled` UI state for modification entry would desynchronize from actual state
- Fixed `ImportError` when trying to import dependency manager on Lesta client since 1.31
- Reorganized `Hotkey` component context menu options
- Updated German localization (CHAMPi)
- Updated localizations
- Code reorganization and cleanup

### 1.6.0
- Added localization support
- Added Belarusian, German, Hungarian, Polish, and Ukrainian language support
- Added `onWindowOpened` event to API (Polyacov_Yury)
- Added tooltip support when using Templates API for options controls creation
- Added survival logic for `isDisabledByBattleType` in case WG changes guiType definitions
- Added default ascending sort for mods list by linkage
- Increased scroll factor for mods list
- Fixed controller naming of `HotkeysController`
- Fixed bug where `StateSwitcher` rendered even when `enabled` key was missing in a mod’s template
- Fixed scrollbar enforcing when content height was smaller than container height
- Fixed mods list blurriness
- Fixed bug where `ColorChoice` popup would render on right mouse button
- Renamed public API method `checkKeySet` to `checkKeyset` to unify naming across the project
- Silenced warning about missing parent view during view loading
- Refactor and cleanup

**P.S.**  
To developers who extend the `ModsSettingsApi` class to create their own settings window instance - please update your code according to the changes.
