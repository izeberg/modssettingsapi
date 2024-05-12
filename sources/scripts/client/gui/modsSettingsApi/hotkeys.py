import collections
import logging

import BigWorld
import game
import Keys
import Event

from gui.modsSettingsApi._constants import *
from gui.modsSettingsApi.utils_common import override

_logger = logging.getLogger(__name__)


class HotkeysContoller(object):

	def __init__(self, api):
		self.api = api
		self.acceptingKey = None
		self.onUpdated = Event.Event()
		override(game, 'handleKeyEvent', self._game_handleKeyEvent)

	def startAccept(self, linkage, varName):
		self.acceptingKey = (linkage, varName, )
		self.onUpdated()

	def stopAccept(self):
		self.acceptingKey = None
		self.onUpdated()

	def clear(self, linkage, varName):
		self.api.config['settings'][linkage][varName] = []
		self.stopAccept()

	def reset(self, linkage, varName):
		defaultSettings = self.api.getSettingsFromTemplate(self.api.config['templates'][linkage])
		self.api.config['settings'][linkage][varName] = self._migrateKeys(defaultSettings[varName])
		self.stopAccept()

	def isKeyDown(self, key):
		if key in SPECIAL_KEYS.SPECIAL_TO_KEYS:
			if not any(map(BigWorld.isKeyDown, SPECIAL_KEYS.SPECIAL_TO_KEYS[key])):
				return False
		elif not BigWorld.isKeyDown(key):
			return False
		return True

	def checkKeySet(self, keys):
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
					self.api.config['settings'][linkage][varName] = list(currentKeys)
					self.onUpdated()
					return True
				if event.isKeyUp():
					self.stopAccept()
					return True
		return baseFunc(event)

	def getHotkeyData(self, linkage, varName):
		keyset = self._migrateKeys(self.api.config['settings'][linkage][varName])
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

	def getAllHotKeys(self):
		result = collections.defaultdict(dict)
		for linkage, template in self.api.config['templates'].items():
			if linkage not in self.api.activeMods:
				continue
			for column in COLUMNS:
				if column not in template:
					continue
				for component in template[column]:
					if component.get('type') == COMPONENT_TYPE.HOTKEY and 'varName' in component:
						result[linkage][component['varName']] = self.getHotkeyData(
							linkage, component.get('varName'))
		return dict(result)
