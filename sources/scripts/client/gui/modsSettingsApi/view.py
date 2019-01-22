import BigWorld
import Event
import game
import Keys
import collections
import json
import os

from debug_utils import LOG_CURRENT_EXCEPTION
from constants import AUTH_REALM

from gui.app_loader.loader import g_appLoader
from gui.Scaleform.framework import ScopeTemplates, ViewSettings, ViewTypes, g_entitiesFactories
from gui.Scaleform.framework.entities.abstract.AbstractWindowView import AbstractWindowView
from gui.Scaleform.framework.managers.loaders import SFViewLoadParams

from gui.modsSettingsApi._constants import VIEW_ALIAS, VIEW_SWF
from gui.modsSettingsApi.utils_common import byteify


__all__ = ('loadView')


def loadView(api):
	g_appLoader.getDefLobbyApp().loadView(SFViewLoadParams(VIEW_ALIAS, VIEW_ALIAS), ctx=api)


class ModsSettingsApiWindow(AbstractWindowView):

	def __init__(self, ctx=None):
		self.api = ctx
		super(ModsSettingsApiWindow, self).__init__(ctx=ctx)

	def _populate(self):
		super(ModsSettingsApiWindow, self)._populate()
		self.api.updateHotKeys += self.as_updateHotKeysS

	def _dispose(self):
		self.api.updateHotKeys -= self.as_updateHotKeysS
		super(ModsSettingsApiWindow, self)._dispose()

	def flashLogS(self, args):
		print "LOG", args

	def sendModsDataS(self, data):
		data = byteify(json.loads(data))
		for linkage in data:
			self.api.updateModSettings(linkage, data[linkage])
		self.api.saveConfig()

	def callButtonsS(self, linkage, varName, value):
		self.api.onButtonClicked(linkage, varName, value)

	def handleHotKeysS(self, linkage, varName, command):
		if command == 'accept':
			self.api.onHotkeyAccept(linkage, varName)
		if command == 'default':
			self.api.onHotkeyDefault(linkage, varName)
		if command == 'clear':
			self.api.onHotkeyClear(linkage, varName)

	def requestModsDataS(self):
		self.api.cleanConfig()
		if self.api.userSettings:
			self.as_setUserSettingsS(self.api.userSettings)
		self.as_setDataS(self.api.getAllTemplates())
		self.as_updateHotKeysS(True)

	def as_setUserSettingsS(self, data):
		if self._isDAAPIInited():
			self.flashObject.as_setUserSettings(data)

	def as_setDataS(self, data):
		if self._isDAAPIInited():
			self.flashObject.as_setData(data)

	def as_updateHotKeysS(self, premature=False):
		if self._isDAAPIInited():
			data = self.api.getAllHotKeys()
			self.flashObject.as_updateHotKeys(data, premature)

	def onWindowClose(self):
		self.api.saveConfig()
		self.destroy()

	def as_isModalS(self):
		if self._isDAAPIInited():
			return False


g_entitiesFactories.addSettings(
	ViewSettings(
		VIEW_ALIAS,
		ModsSettingsApiWindow,
		VIEW_SWF,
		ViewTypes.TOP_WINDOW,
		None,
		ScopeTemplates.DEFAULT_SCOPE,
		isModal=True,
		canDrag=False
	)
)
