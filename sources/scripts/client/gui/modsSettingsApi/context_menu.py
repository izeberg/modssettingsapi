from gui.Scaleform.framework.managers.context_menu import AbstractContextMenuHandler, registerHandlers as registerContextMenuHandlers
from helpers import dependency

from ._constants import *
from .l10n import l10n
from .skeleton import IModsSettingsApiInternal

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


def getContextMenuHandlers():
	return ((HOTKEY_CONTEXT_MENU_HANDLER_ALIAS, HotkeyContextMenuHandler), )

registerContextMenuHandlers(*getContextMenuHandlers())
