import json

from gui.Scaleform.framework import ScopeTemplates, ViewSettings, g_entitiesFactories
from gui.Scaleform.framework.entities.View import View
from gui.Scaleform.framework.managers.context_menu import AbstractContextMenuHandler, registerHandlers as registerContextMenuHandlers
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


def generateStaticDataVO(userSettings):
	return {
		'windowTitle': userSettings.get('windowTitle') or l10n('name'),
		'stateTooltip': userSettings.get('enableButtonTooltip') or makeTooltip(l10n('stateswitcher/tooltip/header'), l10n('stateswitcher/tooltip/body')),
		'buttonOK': userSettings.get('buttonOK') or l10n('buttons/ok'),
		'buttonCancel': userSettings.get('buttonCancel') or l10n('buttons/cancel'),
		'buttonApply': userSettings.get('buttonApply') or l10n('buttons/apply'),
		'buttonClose': userSettings.get('buttonClose') or l10n('buttons/close'),
		'popupColor': userSettings.get('popupColor') or l10n('colorchoice/header')
	}


class ModsSettingsApiWindow(View):
	api = dependency.descriptor(IModsSettingsApiInternal)

	def _populate(self):
		super(ModsSettingsApiWindow, self)._populate()
		self.api.onWindowOpened()
		self.api.updateHotKeys += self.as_updateHotKeysS
		self._blur = CachedBlur(enabled=True, ownLayer=WindowLayer.OVERLAY - 1)

	def _dispose(self):
		self._blur.fini()
		self._blur = None
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

	def hotKeyAction(self, linkage, varName, action):
		if action == HOTKEY_ACTIONS.START_ACCEPT:
			self.api.onHotkeyStartAccept(linkage, varName)
		elif action == HOTKEY_ACTIONS.STOP_ACCEPT:
			self.api.onHotkeyStopAccept(linkage, varName)
		else:
			raise NotImplementedError(action)

	def requestModsData(self):
		self.api.cleanConfig()
		self.as_setStaticDataS(generateStaticDataVO(self.api.userSettings))
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


class HotkeyContextMenuHandler(AbstractContextMenuHandler):
	api = dependency.descriptor(IModsSettingsApiInternal)

	def __init__(self, cmProxy, ctx=None):
		self._linkage = None
		self._varName = None
		self._value = None
		super(HotkeyContextMenuHandler, self).__init__(cmProxy, ctx, {
			HOTKEY_OPTIONS.CLEAR_VALUE: 'clearValue',
			HOTKEY_OPTIONS.RESET_TO_DEFAULT_VALUE: 'resetToDefaultValue'
		})

	def _initFlashValues(self, ctx):
		self._varName = ctx.varName
		self._linkage = ctx.linkage
		self._value = ctx.value

	def _clearFlashValues(self):
		self._linkage = None
		self._varName = None
		self._value = None

	def clearValue(self):
		if self._linkage and self._varName:
			self.api.onHotkeyClear(self._linkage, self._varName)

	def resetToDefaultValue(self):
		if self._linkage and self._varName:
			self.api.onHotkeyDefault(self._linkage, self._varName)

	def _generateOptions(self, ctx=None):
		return [
			self._makeItem(HOTKEY_OPTIONS.CLEAR_VALUE, self.api.userSettings.get('buttonCleanup') or l10n('button/cleanup'), {'enabled': len(self._value)}),
			self._makeItem(HOTKEY_OPTIONS.RESET_TO_DEFAULT_VALUE, self.api.userSettings.get('buttonDefault') or l10n('button/default'))
		]


registerContextMenuHandlers((HOTKEY_CONTEXT_MENU_HANDLER_ALIAS, HotkeyContextMenuHandler))

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
