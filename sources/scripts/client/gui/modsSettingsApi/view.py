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
from helpers import dependency

from gui.shared.personality import ServicesLocator
from gui.shared.view_helpers.blur_manager import CachedBlur
from gui.Scaleform.framework import ScopeTemplates, ViewSettings, g_entitiesFactories
from gui.Scaleform.framework.entities.abstract.AbstractWindowView import AbstractWindowView
from gui.Scaleform.framework.entities.View import View
from gui.Scaleform.framework.managers import context_menu
from gui.Scaleform.framework.managers.loaders import SFViewLoadParams
from gui.Scaleform.locale.SETTINGS import SETTINGS
from gui.Scaleform.locale.VEH_COMPARE import VEH_COMPARE
from frameworks.wulf import WindowLayer

from gui.modsSettingsApi.skeleton import IModsSettingsApiInternal
from gui.modsSettingsApi._constants import MOD_NAME, STATE_TOOLTIP, POPUP_COLOR, VIEW_ALIAS, VIEW_SWF
from gui.modsSettingsApi.utils_common import byteify


__all__ = ('loadView')


def loadView(api):
	ServicesLocator.appLoader.getDefLobbyApp().loadView(SFViewLoadParams(VIEW_ALIAS, VIEW_ALIAS), ctx=api)

def genModApiStaticVO(userSettings):
	return {
		'windowTitle': userSettings.get('windowTitle') or MOD_NAME,
		'stateTooltip': userSettings.get('enableButtonTooltip') or STATE_TOOLTIP,
		'buttonOK': SETTINGS.OK_BUTTON,
		'buttonCancel': SETTINGS.CANCEL_BUTTON,
		'buttonApply': SETTINGS.APPLY_BUTTON,
		'buttonClose': VEH_COMPARE.HEADER_CLOSEBTN_LABEL,
		'popupColor': POPUP_COLOR
	}
	
class ModsSettingsApiWindow(View):
	api = dependency.descriptor(IModsSettingsApiInternal)

	def _populate(self):
		super(ModsSettingsApiWindow, self)._populate()
		self.api.updateHotKeys += self.as_updateHotKeysS
		self._blur = CachedBlur(enabled=True, ownLayer=WindowLayer.OVERLAY-1)

	def _dispose(self):
		self._blur.fini()
		self.api.updateHotKeys -= self.as_updateHotKeysS
		self.api.onWindowClosed()
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
		elif command == 'stopAccept':
			self.api.onHotkeyStopAccept(linkage, varName)
		else:
			raise NotImplementedError(command)

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

class HotkeyContextHandler(context_menu.AbstractContextMenuHandler):
	api = dependency.descriptor(IModsSettingsApiInternal)

	def __init__(self, cmProxy, ctx=None):
		self._linkage = None
		self._varName = None
		super(HotkeyContextHandler, self).__init__(cmProxy, ctx, handlers={
			'setValueToEmpty': 'setValueToEmpty',
			'setValueToDefault': 'setValueToDefault'
		})

	def _initFlashValues(self, ctx):
		self._varName = ctx.varName
		self._linkage = ctx.linkage

	def _clearFlashValues(self):
		self._linkage = None
		self._varName = None

	def setValueToEmpty(self):
		if self._linkage and self._varName:
			self.api.onHotkeyClear(self._linkage, self._varName)

	def setValueToDefault(self):
		if self._linkage and self._varName:
			self.api.onHotkeyDefault(self._linkage, self._varName)

	def _generateOptions(self, ctx=None):
		return [
			self._makeItem('setValueToEmpty', VEH_COMPARE.VEHCONF_BTNCLEANUP, None),
			self._makeItem('setValueToDefault', SETTINGS.DEFAULTBTN, None)
		]

context_menu.registerHandlers(('modsSettingsHotkeyContextHandler', HotkeyContextHandler))

g_entitiesFactories.addSettings(
	ViewSettings(
		VIEW_ALIAS,
		ModsSettingsApiWindow,
		VIEW_SWF,
		WindowLayer.OVERLAY,
		None,
		ScopeTemplates.GLOBAL_SCOPE
	)
)
