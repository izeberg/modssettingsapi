import os

import BigWorld
import Keys
from external_strings_utils import unicode_from_utf8
from helpers import getClientLanguage
from constants import DEFAULT_LANGUAGE

MOD_ID = 'modsSettingsApi'
MOD_ICON = 'gui/maps/icons/modsSettingsApi/icon.png'

L10N_VFS_ROOT = 'mods/izeberg.modssettingsapi/text/'
L10N_FILE_MASK = L10N_VFS_ROOT + '%s.yml'

CIS_LANGUAGES = ('ru', 'be', 'kk', )
DEFAULT_UI_LANGUAGE = 'en'
DEFAULT_CIS_UI_LANGUAGE = 'ru'

VIEW_ALIAS = 'ModsSettingsApiWindow'
VIEW_SWF = 'modsSettingsWindow.swf'

USER_SETTINGS_PATH = os.path.join('mods', 'configs', 'modsSettingsApi.json')

_preferences_path = unicode_from_utf8(BigWorld.wg_getPreferencesFilePath())[1]
CONFIG_PATH = os.path.normpath(os.path.join(os.path.dirname(_preferences_path), 'mods', 'modsettings.dat'))

del _preferences_path

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
