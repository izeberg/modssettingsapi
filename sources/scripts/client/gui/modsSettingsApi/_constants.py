import os
import BigWorld
import Keys

from constants import DEFAULT_LANGUAGE
from helpers import getClientLanguage

VIEW_ALIAS = 'modsSettingsApiWindow'
VIEW_SWF = 'modsSettingsWindow.swf'

USER_SETTINGS_PATH = os.path.join('mods', 'configs', 'modsSettingsApi.json')

from external_strings_utils import unicode_from_utf8
_preferences_path = unicode_from_utf8(BigWorld.wg_getPreferencesFilePath())[1]
CONFIG_PATH = os.path.normpath(os.path.join(os.path.dirname(_preferences_path), 'mods', 'modsettings.dat'))

try:
	_config_dir = os.path.dirname(CONFIG_PATH)
	if not os.path.isdir(_config_dir):
		os.makedirs(_config_dir)
except:
	from debug_utils import LOG_CURRENT_EXCEPTION
	LOG_CURRENT_EXCEPTION()

del _preferences_path, _config_dir

MOD_ICON = 'gui/maps/icons/modsSettingsApi/icon.png'
if 'en' not in (getClientLanguage(), DEFAULT_LANGUAGE, ):
	MOD_NAME = 'Настройка модификаций'
	MOD_DESCRIPTION = 'Данная модификация позволяет легко и просто изменять настройки установленных модов.'
	STATE_TOOLTIP = '{HEADER}Включить / Отключить мод{/HEADER}{BODY}Красный индикатор - мод отключен<br>Зелёный индикатор - мод включен{/BODY}'
	BUTTON_OK = 'OK'
	BUTTON_CANCEL = 'Отменить'
	BUTTON_APPLY = 'Применить'
	BUTTON_CLOSE = 'ЗАКРЫТЬ'
	BUTTON_CLEANUP = 'Очистить'
	BUTTON_DEFAULT = 'По умолчанию'
	POPUP_COLOR = 'ЦВЕТ'
else:
	MOD_NAME = 'Mod configurator'
	MOD_DESCRIPTION = 'This mod allows you to easily configure installed mods.'
	STATE_TOOLTIP = '{HEADER}Enable / Disable mod{/HEADER}{BODY}Red indicator - mod disabled <br> Green indicator - mod enabled{/BODY}'
	BUTTON_OK = 'OK'
	BUTTON_CANCEL = 'Cancel'
	BUTTON_APPLY = 'Apply'
	BUTTON_CLOSE = 'CLOSE'
	BUTTON_CLEANUP = 'Clear'
	BUTTON_DEFAULT = 'Default'
	POPUP_COLOR = 'COLOR'

COLUMNS = ('column1', 'column2')

class COMPONENT_TYPE:
	EMPTY = 'Empty'
	LABEL = 'Label'
	CHECKBOX = 'CheckBox'
	RADIO_BUTTON_GROUP = 'RadioButtonGroup'
	DROPDOWN = 'Dropdown'
	SLIDER = 'Slider'
	TEXT_INPUT = 'TextInput'
	NUMERIC_STEPPER = 'NumericStepper'
	HOTKEY = 'HotKey'
	COLOR_CHOICE = 'ColorChoice'
	RANGE_SLIDER = 'RangeSlider'

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