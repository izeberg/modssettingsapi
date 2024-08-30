import json

from gui.Scaleform.framework import ScopeTemplates, ViewSettings, g_entitiesFactories
from gui.Scaleform.framework.entities.View import View
from gui.Scaleform.framework.managers.loaders import SFViewLoadParams
from gui.shared.personality import ServicesLocator
from gui.shared.view_helpers.blur_manager import CachedBlur
from gui.shared.utils.functions import makeTooltip
from frameworks.wulf import WindowLayer
from skeletons.gui.impl import IGuiLoader
from helpers import dependency

from ._constants import *
from .l10n import l10n
from .skeleton import IModsSettingsApiInternal
from .utils import byteify

__all__ = ('loadView', )


@dependency.replace_none_kwargs(guiLoader=IGuiLoader)
def getParentWindow(guiLoader=None):
	parentWindow = None
	if guiLoader and guiLoader.windowsManager:
		parentWindow = guiLoader.windowsManager.getMainWindow()
	return parentWindow


def loadView(api):
	parent = getParentWindow()
	app = ServicesLocator.appLoader.getDefLobbyApp()
	app.loadView(SFViewLoadParams(VIEW_ALIAS, parent=parent), ctx=api)


def generateLocalizationVO(userSettings):
	return {
		'windowTitle': userSettings.get('windowTitle') or l10n('name'),
		'stateTooltip': userSettings.get('enableButtonTooltip') or makeTooltip(l10n('stateswitcher/tooltip/header'), l10n('stateswitcher/tooltip/body')),
		'popupColor': userSettings.get('popupColor') or l10n('colorchoice/header'),
		'buttonOK': userSettings.get('buttonOK') or l10n('buttons/ok'),
		'buttonCancel': userSettings.get('buttonCancel') or l10n('buttons/cancel'),
		'buttonApply': userSettings.get('buttonApply') or l10n('buttons/apply'),
		'buttonClose': userSettings.get('buttonClose') or l10n('buttons/close'),
	}


class ModsSettingsApiWindowMeta(View):

	def requestModsData(self):
		self._printOverrideError('requestModsData')

	def sendModsData(self, data):
		self._printOverrideError('sendModsData')

	def hotkeyAction(self, linkage, varName, action):
		self._printOverrideError('hotKeyAction')

	def buttonAction(self, linkage, varName, value):
		self._printOverrideError('buttonAction')

	def closeView(self):
		self._printOverrideError('closeView')

	def as_setLocalizationS(self, l10n):
		if self._isDAAPIInited():
			self.flashObject.as_setLocalization(l10n)

	def as_setDataS(self, data):
		if self._isDAAPIInited():
			self.flashObject.as_setData(data)

	def as_setHotkeysS(self, data):
		if self._isDAAPIInited():
			self.flashObject.as_setHotkeys(data)

	def onFocusIn(self, *args):
		if self._isDAAPIInited():
			return False


class ModsSettingsApiWindow(ModsSettingsApiWindowMeta):
	api = dependency.descriptor(IModsSettingsApiInternal)

	def _populate(self):
		super(ModsSettingsApiWindow, self)._populate()
		self.api.onWindowOpened()
		self.api.onHotkeysUpdated += self.__onHotkeysUpdated
		self._blur = CachedBlur(enabled=True, ownLayer=self.layer - 1)

	def _dispose(self):
		self._blur.fini()
		self._blur = None
		self.api.onHotkeysUpdated -= self.__onHotkeysUpdated
		self.api.onWindowClosed()
		super(ModsSettingsApiWindow, self)._dispose()

	def requestModsData(self):
		self.api.clearConfig()
		self.as_setLocalizationS(generateLocalizationVO(self.api.userSettings))
		self.as_setDataS(self.api.getTemplatesForUI())
		self.as_setHotkeysS(self.api.getAllHotkeys())

	def sendModsData(self, data):
		data = byteify(json.loads(data))
		for linkage in data:
			settings = data[linkage]
			self.api.updateModSettings(linkage, settings)
		self.api.configSave()

	def hotkeyAction(self, linkage, varName, action):
		if action == HOTKEY_ACTIONS.START_ACCEPT:
			self.api.onHotkeyStartAccept(linkage, varName)
		elif action == HOTKEY_ACTIONS.STOP_ACCEPT:
			self.api.onHotkeyStopAccept(linkage, varName)
		else:
			raise NotImplementedError(action)

	def buttonAction(self, linkage, varName, value):
		self.api.onButtonClicked(linkage, varName, value)

	def closeView(self):
		self.api.configSave()
		self.destroy()

	def __onHotkeysUpdated(self):
		data = self.api.getAllHotkeys()
		self.as_updateHotkeysS(data)


def getViewSettings():
	return (ViewSettings(VIEW_ALIAS, ModsSettingsApiWindow, VIEW_SWF, WindowLayer.OVERLAY, None, ScopeTemplates.GLOBAL_SCOPE), )

for entry in getViewSettings():
	g_entitiesFactories.addSettings(entry)
