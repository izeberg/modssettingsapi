import os
import BigWorld

from constants import DEFAULT_LANGUAGE

VIEW_ALIAS = 'modsSettingsApiWindow'
VIEW_SWF = 'modsSettingsWindow.swf'

USER_SETTINGS_PATH = os.path.join('mods', 'configs', 'modsSettingsApi.json')

_preferences_path = os.path.dirname(unicode(BigWorld.wg_getPreferencesFilePath(), 'utf-8', errors='ignore'))
CONFIG_PATH = os.path.join(_preferences_path, 'modsettings.dat')
del _preferences_path

MOD_ICON = 'gui/maps/icons/modsSettingsApi/icon.png'
if DEFAULT_LANGUAGE == 'ru':
    MOD_NAME = 'Настройка модов'
    MOD_DESCRIPTION = 'Данная модификация позволяет легко и просто изменять настройки установленных модов.'
else:
    MOD_NAME = 'Mod configurator'
    MOD_DESCRIPTION = 'This mod allows you to easily configure installed mods.'

