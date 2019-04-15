import BigWorld
import Event
import game
import Keys
import collections
import json
import GUI
import os

from debug_utils import LOG_CURRENT_EXCEPTION
from constants import AUTH_REALM

from gui.shared.personality import ServicesLocator
from gui.app_loader.settings import APP_NAME_SPACE
from gui.Scaleform.genConsts.APP_CONTAINERS_NAMES import APP_CONTAINERS_NAMES
from gui.Scaleform.framework import ScopeTemplates, ViewSettings, ViewTypes, g_entitiesFactories
from gui.Scaleform.framework.entities.abstract.AbstractWindowView import AbstractWindowView
from gui.Scaleform.framework.entities.View import View
from gui.Scaleform.framework.managers.loaders import SFViewLoadParams

from gui.modsSettingsApi._constants import VIEW_ALIAS, VIEW_SWF
from gui.modsSettingsApi.utils_common import byteify


__all__ = ('loadView')


def loadView(api):
	ServicesLocator.appLoader.getDefLobbyApp().loadView(SFViewLoadParams(VIEW_ALIAS, VIEW_ALIAS), ctx=api)

def genModApiStaticVO(userSettings):
	from gui.Scaleform.locale.SETTINGS import SETTINGS
	from gui.Scaleform.locale.VEH_COMPARE import VEH_COMPARE
	from gui.modsSettingsApi._constants import MOD_NAME, STATE_TOOLTIP, POPUP_COLOR
	
	return {
		'windowTitle': userSettings.get('windowTitle') or MOD_NAME,
		'stateTooltip': userSettings.get('enableButtonTooltip') or STATE_TOOLTIP,
		'buttonOK': SETTINGS.OK_BUTTON,
		'buttonCancel': SETTINGS.CANCEL_BUTTON,
		'buttonApply': SETTINGS.APPLY_BUTTON,
		'buttonClose': VEH_COMPARE.HEADER_CLOSEBTN_LABEL,
		'contextDefault': SETTINGS.DEFAULTBTN,
		'contextClean': VEH_COMPARE.VEHCONF_BTNCLEANUP,
		'popupColor': POPUP_COLOR
	}
	
class ModsSettingsApiWindow(View):

	def __init__(self, ctx=None):
		self.api = ctx
		super(ModsSettingsApiWindow, self).__init__(ctx=ctx)

	def _populate(self):
		super(ModsSettingsApiWindow, self)._populate()
		self.api.updateHotKeys += self.as_updateHotKeysS
		
		self._blur = GUI.WGUIBackgroundBlur()
		app = ServicesLocator.appLoader.getApp(APP_NAME_SPACE.SF_LOBBY)
		if app:
			self._blur.enable = True
			ownLayer = APP_CONTAINERS_NAMES.VIEWS
			blurAnimRepeatCount = 10
			layers = [
				APP_CONTAINERS_NAMES.SYSTEM_MESSAGES,
				APP_CONTAINERS_NAMES.SERVICE_LAYOUT,
				APP_CONTAINERS_NAMES.MARKER
			]
			app.blurBackgroundViews(ownLayer, layers, blurAnimRepeatCount)
	
	def _dispose(self):
		
		if self._blur is not None:
			self._blur.enable = False
			self._blur = None
		app = ServicesLocator.appLoader.getApp(APP_NAME_SPACE.SF_LOBBY)
		if app:
			app.unblurBackgroundViews()
		
		self.api.updateHotKeys -= self.as_updateHotKeysS
		super(ModsSettingsApiWindow, self)._dispose()

	def sendModsData(self, data):
		data = byteify(json.loads(data))
		for linkage in data:
			self.api.updateModSettings(linkage, data[linkage])
		self.api.configSave()

	def buttonAction(self, linkage, varName, value):
		self.api.onButtonClicked(linkage, varName, value)

	def hotKeyAction(self, linkage, varName, command):
		if command == 'startAccept':
			self.api.onHotkeyStartAccept(linkage, varName)
		if command == 'stopAccept':
			self.api.onHotkeyStopAccept(linkage, varName)
		if command == 'default':
			self.api.onHotkeyDefault(linkage, varName)
		if command == 'clean':
			self.api.onHotkeyClear(linkage, varName)

	def requestModsData(self):
		self.api.cleanConfig()
		self.as_setStaticDataS(genModApiStaticVO(self.api.userSettings))
		self.as_setDataS(self.api.getTemplatesForUI())
		self.as_updateHotKeysS()

	def as_setStaticDataS(self, data):
		if self._isDAAPIInited():
			self.flashObject.as_setStaticData(data)

	def as_setDataS(self, data):
		if self._isDAAPIInited():
			self.flashObject.as_setData(data)

	def as_updateHotKeysS(self):
		if self._isDAAPIInited():
			data = self.api.getAllHotKeys()
			self.flashObject.as_updateHotKeys(data)
	
	def closeView(self):
		self.api.configSave()
		self.destroy()
	
	def onFocusIn(self, *args):
		if self._isDAAPIInited():
			return False	

g_entitiesFactories.addSettings(
	ViewSettings(
		VIEW_ALIAS,
		ModsSettingsApiWindow,
		VIEW_SWF,
		ViewTypes.WINDOW,
		None,
		ScopeTemplates.GLOBAL_SCOPE
	)
)
