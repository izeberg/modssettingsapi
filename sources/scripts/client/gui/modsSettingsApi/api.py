import os
import functools
import copy
import logging

import BigWorld
import cPickle
import Event
from helpers import dependency

from gui.modsListApi import g_modsListApi

from gui.modsSettingsApi.l10n import l10n
from gui.modsSettingsApi.hotkeys import HotkeysController
from gui.modsSettingsApi.view import loadView
from gui.modsSettingsApi.skeleton import IModsSettingsApiInternal
from gui.modsSettingsApi._constants import *
from gui.modsSettingsApi.utils_common import jsonLoad, jsonDump

_logger = logging.getLogger(__name__)


class ModsSettingsApi(IModsSettingsApiInternal):

	def __init__(self):
		super(ModsSettingsApi, self).__init__()
		self.__saveCallbackID = None
		self.activeMods = set()
		self.config = {
			'templates': {},
			'settings': {},
			'data': {},
		}
		self.userSettings = {}

		self.onWindowOpened = Event.Event()
		self.onWindowClosed = Event.Event()
		self.updateHotKeys = Event.Event()
		self.onButtonClicked = Event.Event()
		self.onSettingsChanged = Event.Event()

		self.hotkeys = HotkeysController(self)
		self.hotkeys.onUpdated += self.updateHotKeys

		self.settingsLoad()
		self.configLoad()

		g_modsListApi.addModification(
			id=MOD_ID,
			name=self.userSettings.get('modsListApiName') or l10n('name'),
			description=self.userSettings.get('modsListApiDescription') or l10n('description'),
			icon=self.userSettings.get('modsListApiIcon') or MOD_ICON,
			enabled=True, login=True, lobby=True,
			callback=functools.partial(loadView, self)
		)

		dependency._g_manager.addInstance(IModsSettingsApiInternal, self)

	def settingsLoad(self):
		if not os.path.exists(USER_SETTINGS_PATH):
			return
		try:
			with open(USER_SETTINGS_PATH, 'rb') as settingsFile:
				self.userSettings = jsonLoad(settingsFile)
		except Exception:
			_logger.exception('Error occured when trying to load user settings!')

	def configLoad(self):
		if not os.path.exists(CONFIG_PATH):
			self.configSave()
			return
		try:
			with open(CONFIG_PATH, 'rb') as configFile:
				self.config = jsonLoad(configFile)
				self.config.setdefault('data', {})
		except Exception:
			_logger.exception('Error occured when trying to load config!')

	def configSave(self):
		if self.__saveCallbackID is None:
			self.__saveCallbackID = BigWorld.callback(0.0, self.__save)

	def __save(self):
		self.__saveCallbackID = None
		try:
			configDir = os.path.dirname(CONFIG_PATH)
			if not os.path.isdir(configDir):
				os.makedirs(configDir)
		except Exception:
			_logger.exception('Error occured when trying to recrate folder structure for config file!')
		try:
			with open(CONFIG_PATH, 'wb') as configFile:
				configFile.write(jsonDump(self.config, True))
		except Exception:
			_logger.exception('Error occured when trying to save config!')

	def getSettingsFromTemplate(self, template):
		result = dict()
		if 'enabled' in template:
			result['enabled'] = template['enabled']
		for column in COLUMNS:
			if column in template:
				result.update(self.getSettingsFromColumn(template[column]))
		return result

	def getSettingsFromColumn(self, column):
		result = dict()
		for elem in column:
			if 'varName' in elem and 'value' in elem:
				result[elem['varName']] = elem['value']
		return result

	def compareTemplates(self, newTemplate, oldTemplate):
		if 'settingsVersion' in newTemplate and 'settingsVersion' in oldTemplate:
			return newTemplate['settingsVersion'] > oldTemplate['settingsVersion']
		return jsonDump(newTemplate, True) != jsonDump(oldTemplate, True)

	def setModTemplate(self, linkage, template, callback, buttonHandler=None):
		try:
			self.activeMods.add(linkage)
			currentTemplate = self.config['templates'].get(linkage)
			if not currentTemplate or self.compareTemplates(template, currentTemplate):
				self.config['templates'][linkage] = template
				self.config['settings'][linkage] = self.getSettingsFromTemplate(template)
				self.configSave()
			self.onSettingsChanged += callback
			if buttonHandler is not None:
				self.onButtonClicked += buttonHandler
			return self.getModSettings(linkage, self.config['templates'][linkage])
		except Exception:
			_logger.exception('Error occured when trying to register mod template!')

	def registerCallback(self, linkage, callback, buttonHandler=None):
		self.activeMods.add(linkage)
		self.onSettingsChanged += callback
		if buttonHandler is not None:
			self.onButtonClicked += buttonHandler

	def getModSettings(self, linkage, template):
		result = None
		if template:
			currentTemplate = self.config['templates'].get(linkage)
			if currentTemplate:
				if not self.compareTemplates(template, currentTemplate):
					result = self.config['settings'].get(linkage)
				self.activeMods.add(linkage)
		return result

	def updateModSettings(self, linkage, newSettings):
		self.config['settings'][linkage] = newSettings
		self.onSettingsChanged(linkage, newSettings)

	def cleanConfig(self):
		for linkage in self.config['templates'].keys():
			if linkage not in self.activeMods:
				del self.config['templates'][linkage]
				del self.config['settings'][linkage]

	def getTemplatesForUI(self):
		# Make copy of current templates and updates component's values from actual settings
		templates = []
		linkages = sorted(self.config['templates'], key=str.lower)
		for linkage in linkages:
			template = copy.deepcopy(self.config['templates'][linkage])
			template['linkage'] = linkage
			settings = self.getModSettings(linkage, template)
			for column in COLUMNS:
				if column in template:
					for component in template[column]:
						if 'varName' in component:
							component['value'] = settings[component['varName']]
			templates.append(template)
		return templates

	def onHotkeyStartAccept(self, linkage, varName):
		return self.hotkeys.startAccept(linkage, varName)

	def onHotkeyStopAccept(self, linkage, varName):
		return self.hotkeys.stopAccept()

	def onHotkeyDefault(self, linkage, varName):
		return self.hotkeys.reset(linkage, varName)

	def onHotkeyClear(self, linkage, varName):
		return self.hotkeys.clear(linkage, varName)

	def getAllHotKeys(self):
		return self.hotkeys.getAllHotKeys()

	def checkKeySet(self, keys):
		return self.hotkeys.checkKeySet(keys)

	def saveModData(self, linkage, version, data):
		self.config['data'][linkage] = {
			'version': version,
			'data': cPickle.dumps(data, -1),
		}
		self.configSave()

	def getModData(self, linkage, version, default):
		data = self.config['data']
		if linkage not in data or data[linkage]['version'] != version:
			self.saveModData(linkage, version, default)
		return cPickle.loads(data[linkage]['data'])
