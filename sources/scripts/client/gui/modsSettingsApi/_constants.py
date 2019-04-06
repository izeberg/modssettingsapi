import os
import BigWorld
import Keys

from constants import DEFAULT_LANGUAGE

VIEW_ALIAS = 'modsSettingsApiWindow'
VIEW_SWF = 'modsSettingsWindow.swf'

USER_SETTINGS_PATH = os.path.join('mods', 'configs', 'modsSettingsApi.json')

_preferences_path = os.path.dirname(unicode(BigWorld.wg_getPreferencesFilePath(), 'utf-8', errors='ignore'))
if not os.path.exists(_preferences_path):
	os.makedirs(_preferences_path)

CONFIG_PATH = os.path.join(_preferences_path, 'modsettings.dat')
del _preferences_path

MOD_ICON = 'gui/maps/icons/modsSettingsApi/icon.png'
if DEFAULT_LANGUAGE == 'ru':
    MOD_NAME = 'Настройка модификаций'
    MOD_DESCRIPTION = 'Данная модификация позволяет легко и просто изменять настройки установленных модов.'
    STATE_TOOLTIP = '{HEADER}Включить / Отключить мод{/HEADER}{BODY}Красный индикатор - мод отключен<br>Зелёный индикатор - мод включен{/BODY}'
    POPUP_COLOR = 'ЦВЕТ'
else:
    MOD_NAME = 'Mod configurator'
    MOD_DESCRIPTION = 'This mod allows you to easily configure installed mods.'
    STATE_TOOLTIP = '{HEADER}Enable / Disable mod {/HEADER}{BODY} Red indicator - mod disabled <br> Green indicator - mod enabled{/BODY}'
    POPUP_COLOR = 'COLOR'

COLUMNS = ('column1', 'column2')

class SPECIAL_KEYS:
	KEY_ALT, KEY_CONTROL, KEY_SHIFT = range(-1, -4, -1)
	SPECIAL_TO_KEYS = {
		KEY_ALT: (Keys.KEY_LALT, Keys.KEY_RALT),
		KEY_CONTROL: (Keys.KEY_LCONTROL, Keys.KEY_RCONTROL),
		KEY_SHIFT: (Keys.KEY_LSHIFT, Keys.KEY_RSHIFT),
	}
	KEYS_TO_SPECIAL = {}
	for special, keys in SPECIAL_TO_KEYS.items():
		for key in keys:
			KEYS_TO_SPECIAL[key] = special
	ALL = SPECIAL_TO_KEYS.keys()

EXCLUDED_KEYS = {
	Keys.KEY_NONE, Keys.KEY_RETURN, 
	Keys.KEY_MOUSE0, Keys.KEY_LEFTMOUSE, Keys.KEY_MOUSE1, 
	Keys.KEY_RIGHTMOUSE, Keys.KEY_MOUSE2, Keys.KEY_MIDDLEMOUSE
}