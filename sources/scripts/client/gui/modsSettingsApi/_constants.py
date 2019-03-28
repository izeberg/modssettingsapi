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
    MOD_NAME = 'Настройка модификаций'
    MOD_DESCRIPTION = 'Данная модификация позволяет легко и просто изменять настройки установленных модов.'
    STATE_TOOLTIP = '{HEADER}Включить / Отключить мод{/HEADER}{BODY}Красный индикатор - мод отключен<br>Зелёный индикатор - мод включен{/BODY}'
    POPUP_COLOR = 'ЦВЕТ'
else:
    MOD_NAME = 'Mod configurator'
    MOD_DESCRIPTION = 'This mod allows you to easily configure installed mods.'
    STATE_TOOLTIP = '{HEADER}Enable / Disable mod {/ HEADER} {BODY} Red indicator - mod disabled <br> Green indicator - mod enabled{/BODY}'
    POPUP_COLOR = 'COLOR'
