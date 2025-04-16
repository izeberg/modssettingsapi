import collections
import logging

import BigWorld
import game
import Keys

from ._constants import *
from .utils import override, deprecated

_logger = logging.getLogger(__name__)

class HotkeysController(object):

	def __init__(self, api):
		self.api = api
		self.acceptingKey = None
		override(game, 'handleKeyEvent', self._game_handleKeyEvent)

	def startAccept(self, linkage, varName):
		self.acceptingKey = (linkage, varName, )
		self.api.onHotkeysUpdated()

	def stopAccept(self):
		self.acceptingKey = None
		self.api.onHotkeysUpdated()

	def clear(self, linkage, varName):
		self.api.state['settings'][linkage][varName] = []
		self.stopAccept()

	def reset(self, linkage, varName):
		defaultSettings = self.api.getSettingsFromTemplate(self.api.state['templates'][linkage])
		self.api.state['settings'][linkage][varName] = self._migrateKeys(defaultSettings[varName])
		self.stopAccept()

	def isKeyDown(self, key):
		if key in SPECIAL_KEYS.SPECIAL_TO_KEYS:
			if not any(map(BigWorld.isKeyDown, SPECIAL_KEYS.SPECIAL_TO_KEYS[key])):
				return False
		elif not BigWorld.isKeyDown(key):
			return False
		return True

	def checkKeyset(self, keys):
		if not keys:
			return False
		return all(map(self.isKeyDown, self._migrateKeys(keys)))

	def _migrateKeys(self, keys):
		migrated = set()
		for key in keys:
			if isinstance(key, collections.Iterable):
				# Make flat set of keys
				migrated |= self._migrateKeys(key)
			else:
				# Migrate special keys to virtual keys
				migrated.add(SPECIAL_KEYS.KEYS_TO_SPECIAL.get(key, key))
		return migrated

	def _game_handleKeyEvent(self, baseFunc, event):
		if self.acceptingKey:
			if event.key == Keys.KEY_ESCAPE:
				self.stopAccept()
				return True
			if event.key not in EXCLUDED_KEYS:
				if event.isKeyDown():
					currentKeys = {event.key}
					for key, special in SPECIAL_KEYS.KEYS_TO_SPECIAL.iteritems():
						if key not in currentKeys and BigWorld.isKeyDown(key):
							currentKeys.add(special)
					linkage, varName = self.acceptingKey
					self.api.state['settings'][linkage][varName] = list(currentKeys)
					self.api.onHotkeysUpdated()
					return True
				if event.isKeyUp():
					self.stopAccept()
					return True
		return baseFunc(event)

	def getHotkeyData(self, linkage, varName):
		settings = self.api.state['settings'][linkage]
		keyset = self._migrateKeys(settings[varName])
		data = {
			'linkage': linkage,
			'varName': varName,
			'text': '',
			'keyset': keyset,
			'isEmpty': not bool(keyset),
			'isAccepting': self.acceptingKey == (linkage, varName),
			'modifierAlt': False,
			'modifierCtrl': False,
			'modiferShift': False
		}
		if keyset:
			for item in keyset:
				if item not in SPECIAL_KEYS.ALL:
					for attr in dir(Keys):
						if attr.startswith('KEY_') and getattr(Keys, attr) == item:
							data['text'] = attr[len('KEY_'):]
				else:
					data['modifierAlt'] = data['modifierAlt'] or item == SPECIAL_KEYS.KEY_ALT
					data['modifierCtrl'] = data['modifierCtrl'] or item == SPECIAL_KEYS.KEY_CONTROL
					data['modiferShift'] = data['modiferShift'] or item == SPECIAL_KEYS.KEY_SHIFT
			if not data['text']:
				if data['modifierAlt']:
					data['text'] = 'ALT'
					data['modifierAlt'] = False
				elif data['modifierCtrl']:
					data['text'] = 'CTRL'
					data['modifierCtrl'] = False
				elif data['modiferShift']:
					data['text'] = 'SHIFT'
					data['modiferShift'] = False
		return data

	def getAllHotkeys(self):
		result = collections.defaultdict(dict)
		templates = self.api.state['templates']
		for linkage, template in templates.items():
			if linkage not in self.api.activeMods:
				continue
			for column in COLUMNS:
				if column not in template:
					continue
				for component in template[column]:
					if component.get('type') == COMPONENT_TYPE.HOTKEY and 'varName' in component:
						hotkeyData = self.getHotkeyData(linkage, component.get('varName'))
						result[linkage][component['varName']] = hotkeyData
		return dict(result)

# Backwards compatibility with mods that still use wrongly named class in imports
# TODO: delete in next release
class HotkeysContoller(HotkeysController):

	@deprecated('HotkeysController')
	def __init__(self, api):
		super(HotkeysContoller, self).__init__(api)
		_logger.warning('You are using deprecated controller class. Please use HotkeysController instead. The backwards compatibility support will be removed in future updates.')
