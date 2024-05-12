# CHANGELOG

### WIP

- all: code format and cleanup
- python: migrate to logging instead of debug_utils
- python: move config directory creation from constants to API
- python/constants: use proper name for view alias
- python/api: added onWindowOpened event to API (Polyacov_Yury)
- python/hotkeys (BREAKING): controller naming fix (HotkeysContoller -> HotkeysController)
- python/hotkeys: hotkey context menu handler refactor
- python/utils: added survival logic for isDisabledByBattleType in cases when WG changes gui types definitions
- python/view: silence warning about missing parent view in view loading logic
- python/view: expose HotkeyControl value to context menu to make empty value option unactive
- as3: unify components naming
- as3/components: increase scroll factor and don't enforce scrollbar even when content is smaller than container height
- as3/controls: StatusSwitcher refactor
- as3/controls: fixed component naming (ColorChoise -> ColorChoice)
- as3/controls: fixed internal variables naming (blueSlider) in ColorChoice
