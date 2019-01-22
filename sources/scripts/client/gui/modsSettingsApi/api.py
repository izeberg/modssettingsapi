import BigWorld
import Event
import game
import Keys
import collections
import json
import os
import functools

from debug_utils import LOG_CURRENT_EXCEPTION
from constants import AUTH_REALM

from gui.modsListApi import g_modsListApi

from gui.modsSettingsApi.view import loadView
from gui.modsSettingsApi._constants import USER_SETTINGS_PATH, CONFIG_PATH
from gui.modsSettingsApi._constants import MOD_ICON, MOD_NAME, MOD_DESCRIPTION
from gui.modsSettingsApi.utils_common import override, jsonLoad, jsonDump

class ModsSettingsApi(object):
	def __init__(self):
		self.__activeMods = list()
		self.__config = dict()
		self.__config['templates'] = dict()
		self.__config['settings'] = dict()
		
		self.onSettingsChanged = Event.Event()
		self.onButtonClicked = Event.Event()
		self.updateHotKeys = Event.Event()
		
		self.userSettings = {}
	
		self.__userSettingsLoad()
		self.__configLoad()
		self.__initModsList()
		
		self.__acceptingKey = None
		override(game, 'handleKeyEvent', self.__game_handleKeyEvent)
		
	def __initModsList(self):
		name = self.userSettings.get('modsListApiName') or MOD_NAME
		description = self.userSettings.get('modsListApiDescription') or MOD_DESCRIPTION
		icon = self.userSettings.get('modsListApiIcon') or MOD_ICON
	
		g_modsListApi.addModification(
			id='modsSettingsApi',
			name=name, 
			description=description, 
			icon=icon, 
			enabled=True, 
			login=True, 
			lobby=True,
			callback=functools.partial(loadView, self)
		)
	
	def __userSettingsLoad(self):
		if os.path.exists(USER_SETTINGS_PATH):
			try:
				with open(USER_SETTINGS_PATH, 'rb') as config:
					self.userSettings = jsonLoad(config)
			except:
				LOG_CURRENT_EXCEPTION()
	
	def __configLoad(self):
		if os.path.exists(CONFIG_PATH):
			try:
				with open(CONFIG_PATH, 'rb') as config:
					self.__config = jsonLoad(config)
			except:
				LOG_CURRENT_EXCEPTION()
		else:
			self.saveConfig()
	
	def saveConfig(self):
		try:
			with open(CONFIG_PATH, 'wb') as config:
				config.write(jsonDump(self.__config))
		except:
			LOG_CURRENT_EXCEPTION()

	def __getSettingsFromTemplate(self, template):
		result = dict()
		result.update(self.__getSettingsFromColumn(template['column1']))
		result.update(self.__getSettingsFromColumn(template['column2']))
		if 'enabled' in template:
			result['enabled'] = template['enabled']
		return result
		
	def __getSettingsFromColumn(self, column):
		result = dict()
		for elem in column:
			if 'varName' in elem and 'value' in elem:
				result[elem['varName']] = elem['value']
		return result
			
	def setModTemplate(self, linkage, template, callback, buttonHandler = None):
		try:
			if linkage not in self.__activeMods:
				self.__activeMods.append(linkage)
			
			if 'column1' in template:
				for component in template['column1']:
					if 'type' in component and component['type'] == 'HotKey' and 'value' in component:
						component['defaultValue'] = component['value']
			if 'column2' in template:
				for component in template['column2']:
					if 'type' in component and component['type'] == 'HotKey' and 'value' in component:
						component['defaultValue'] = component['value']
			
			currentTemplate = self.__getModTemplate(linkage)
			if currentTemplate:
				if template['settingsVersion'] > currentTemplate['settingsVersion']:
					self.__config['templates'][linkage] = template
					self.__config['settings'][linkage] = self.__getSettingsFromTemplate(template)
					self.saveConfig()
			else:
				self.__config['templates'][linkage] = template
				self.__config['settings'][linkage] = self.__getSettingsFromTemplate(template)
				self.saveConfig()
			
			self.onSettingsChanged += callback
			if buttonHandler is not None:
				self.onButtonClicked += buttonHandler
			
			return self.getModSettings(linkage, self.__config['templates'][linkage])
		except:
			LOG_CURRENT_EXCEPTION()			
		
	def __getModTemplate(self, linkage):
		try:
			return self.__config['templates'].get(linkage)
		except:
			LOG_CURRENT_EXCEPTION()
	
	def registerCallback(self, linkage, callback, buttonHandler = None):
		if linkage not in self.__activeMods:
			self.__activeMods.append(linkage)
		self.onSettingsChanged += callback
		if buttonHandler is not None:
			self.onButtonClicked += buttonHandler
			
	def getModSettings(self, linkage, template=None):
		result = None
		if template:
			currentTemplate = self.__getModTemplate(linkage)
			if currentTemplate:
				if template['settingsVersion'] <= currentTemplate['settingsVersion']:
					result = self.__config['settings'].get(linkage)
			
				if linkage not in self.__activeMods:
					self.__activeMods.append(linkage)
		return result
		
	def updateModSettings(self, linkage, newSettings):
		self.__config['settings'][linkage] = newSettings
		self.__updateModTemplate(linkage, newSettings)
		self.onSettingsChanged(linkage, newSettings)
			
	def __updateModTemplate(self, linkage, settings):
		modTemplate = self.__config['templates'][linkage]
		if 'enabled' in self.__config['settings'][linkage]:
			modTemplate['enabled'] = self.__config['settings'][linkage]['enabled']
		if 'column1' in modTemplate:
			for component in modTemplate['column1']:
				if 'varName' in component:
					component['value'] = self.__config['settings'][linkage][component['varName']]
		if 'column2' in modTemplate:
			for component in modTemplate['column2']:
				if 'varName' in component:
					component['value'] = self.__config['settings'][linkage][component['varName']]
		self.__config['templates'][linkage] = modTemplate
		
	def cleanConfig(self):
		for linkage in self.__config['templates'].keys():
			if linkage not in self.__activeMods:
				del self.__config['templates'][linkage]
				del self.__config['settings'][linkage]
			
	def getAllTemplates(self):
		return self.__config['templates']
	
	def __game_handleKeyEvent(self, baseFunc, event):
		if self.__acceptingKey is not None:
			
			if event.key == Keys.KEY_ESCAPE:
				self.__acceptingKey = None
				self.updateHotKeys()
				return True
			
			if event.isKeyUp() and event.key not in [0, Keys.KEY_CAPSLOCK, Keys.KEY_RETURN, Keys.KEY_MOUSE0, Keys.KEY_LEFTMOUSE, Keys.KEY_MOUSE1, Keys.KEY_RIGHTMOUSE, Keys.KEY_MOUSE2, Keys.KEY_MIDDLEMOUSE]:
				
				new_keyset = []
				
				if event.key == Keys.KEY_LCONTROL or event.key == Keys.KEY_RCONTROL: new_keyset.append([Keys.KEY_LCONTROL, Keys.KEY_RCONTROL])
				if event.key == Keys.KEY_LSHIFT or event.key == Keys.KEY_RSHIFT: new_keyset.append([Keys.KEY_LSHIFT, Keys.KEY_RSHIFT])
				if event.key == Keys.KEY_LALT or event.key == Keys.KEY_RALT: new_keyset.append([Keys.KEY_LALT, Keys.KEY_RALT])
				
				if BigWorld.isKeyDown(Keys.KEY_LCONTROL) or BigWorld.isKeyDown(Keys.KEY_RCONTROL): new_keyset.append([Keys.KEY_LCONTROL, Keys.KEY_RCONTROL])
				if BigWorld.isKeyDown(Keys.KEY_LSHIFT) or BigWorld.isKeyDown(Keys.KEY_RSHIFT): new_keyset.append([Keys.KEY_LSHIFT, Keys.KEY_RSHIFT])
				if BigWorld.isKeyDown(Keys.KEY_LALT) or BigWorld.isKeyDown(Keys.KEY_RALT): new_keyset.append([Keys.KEY_LALT, Keys.KEY_RALT])
				
				linkage, varName = self.__acceptingKey
				self.__config['settings'][linkage][varName] = new_keyset
				
				template = self.__config['templates'][linkage]
				if 'column1' in template:
					for component in template['column1']:
						if 'varName' in component and component['varName'] == varName:
							component['value'] = new_keyset	
				if 'column2' in template:
					for component in template['column2']:
						if 'varName' in component and component['varName'] == varName:
							component['value'] = new_keyset	
							
				self.__acceptingKey = None
				self.updateHotKeys()
				return True
			
			if event.isKeyDown() and event.key not in [0, Keys.KEY_LCONTROL, Keys.KEY_LSHIFT, Keys.KEY_LALT, Keys.KEY_RCONTROL, Keys.KEY_RSHIFT, Keys.KEY_RALT, Keys.KEY_CAPSLOCK, Keys.KEY_RETURN,
				Keys.KEY_MOUSE0, Keys.KEY_LEFTMOUSE, Keys.KEY_MOUSE1, Keys.KEY_RIGHTMOUSE, Keys.KEY_MOUSE2, Keys.KEY_MIDDLEMOUSE]:
				
				new_keyset = [event.key]
				
				if BigWorld.isKeyDown(Keys.KEY_LCONTROL) or BigWorld.isKeyDown(Keys.KEY_RCONTROL): new_keyset.append([Keys.KEY_LCONTROL, Keys.KEY_RCONTROL])
				if BigWorld.isKeyDown(Keys.KEY_LSHIFT) or BigWorld.isKeyDown(Keys.KEY_RSHIFT): new_keyset.append([Keys.KEY_LSHIFT, Keys.KEY_RSHIFT])
				if BigWorld.isKeyDown(Keys.KEY_LALT) or BigWorld.isKeyDown(Keys.KEY_RALT): new_keyset.append([Keys.KEY_LALT, Keys.KEY_RALT])
				
				linkage, varName = self.__acceptingKey
				self.__config['settings'][linkage][varName] = new_keyset
				
				template = self.__config['templates'][linkage]
				if 'column1' in template:
					for component in template['column1']:
						if 'varName' in component and component['varName'] == varName:
							component['value'] = new_keyset	
				if 'column2' in template:
					for component in template['column2']:
						if 'varName' in component and component['varName'] == varName:
							component['value'] = new_keyset	
							
				self.__acceptingKey = None
				self.updateHotKeys()
				return True
		
		return baseFunc(event)
	
	def onHotkeyAccept(self, linkage, varName):
		if self.__acceptingKey is not None:
			self.__acceptingKey = (linkage, varName)
			self.updateHotKeys()
		else:
			self.__acceptingKey = (linkage, varName)
	
	def onHotkeyDefault(self, linkage, varName):
		template = self.__config['templates'][linkage]
		if 'column1' in template:
			for component in template['column1']:
				if 'varName' in component and component['varName'] == varName:
					component['value'] = component['defaultValue']
					self.__config['settings'][linkage][varName] = component['defaultValue']
		if 'column2' in template:
			for component in template['column2']:
				if 'varName' in component and component['varName'] == varName:
					component['value'] = component['defaultValue']
					self.__config['settings'][linkage][varName] = component['defaultValue']
		self.__acceptingKey = None
		self.updateHotKeys()
		
	def onHotkeyClear(self, linkage, varName):
		self.__config['settings'][linkage][varName] = []
		template = self.__config['templates'][linkage]
		if 'column1' in template:
			for component in template['column1']:
				if 'varName' in component and component['varName'] == varName:
					component['value'] = []
		if 'column2' in template:
			for component in template['column2']:
				if 'varName' in component and component['varName'] == varName:
					component['value'] = []
		self.__acceptingKey = None
		self.updateHotKeys()
	
	def getAllHotKeys(self):
		result = {}
		
		def parseKeySet(keyset):
			
			if not len(keyset):
				return [False, '', False, False, False]
			
			key_name = None
			is_alt = False
			is_control = False
			is_shift = False
			
			for item in keyset:
				if isinstance(item, list):
					for key in item:
						if key == Keys.KEY_LALT or key == Keys.KEY_RALT:	
							is_alt = True
						if key == Keys.KEY_LCONTROL or key == Keys.KEY_LCONTROL:	
							is_control = True
						if key == Keys.KEY_LSHIFT or key == Keys.KEY_LSHIFT:	
							is_shift = True
				else:
					for attr in dir(Keys):
						if 'KEY_' in attr and getattr(Keys, attr) == item:
							key_name = attr.replace('KEY_', '')
			
			if not key_name:
				if is_alt:
					key_name = 'ALT'
					is_alt = False
				elif is_control:
					key_name = 'CTRL'
					is_control = False
				elif is_shift:
					key_name = 'SHIFT'
					is_shift = False

			
			return [True, key_name, is_alt, is_control, is_shift]
		
		for linkage in self.__config['templates'].keys():
			if linkage in self.__activeMods:
				
				template = self.__config['templates'][linkage]
				
				if 'column1' in template:
					for component in template['column1']:
						if 'type' in component  and component['type'] == 'HotKey' and 'varName' in component and 'value' in component:
							if linkage not in result: result[linkage] = {}
							keySet = parseKeySet(component['value'])
							value = self.__config['settings'][linkage][component['varName']]
							c_linkage, c_varName = '', ''
							if self.__acceptingKey is not None:
								c_linkage, c_varName = self.__acceptingKey
							result[linkage][component['varName']] = {
								'is_setted': keySet[0],
								'is_alt': keySet[2],
								'is_control': keySet[3],
								'is_shift': keySet[4],
								'button_text': keySet[1],
								'accepting': c_linkage + c_varName,
								'value': value
							}
				if 'column2' in template:
					for component in template['column2']:
						if 'type' in component  and component['type'] == 'HotKey' and 'varName' in component and 'value' in component:
							if linkage not in result: result[linkage] = {}
							keySet = parseKeySet(component['value'])
							value = self.__config['settings'][linkage][component['varName']]
							c_linkage, c_varName = '', ''
							if self.__acceptingKey is not None:
								c_linkage, c_varName = self.__acceptingKey
							result[linkage][component['varName']] = {
								'is_setted': keySet[0],
								'is_alt': keySet[2],
								'is_control': keySet[3],
								'is_shift': keySet[4],
								'button_text': keySet[1],
								'accepting': c_linkage + c_varName,
								'value': value
							}
		return result
	
	def checkKeySet(self, keyset):
		if not keyset:
			return False
		result = True
		for item in keyset:
			if isinstance(item, int) and not BigWorld.isKeyDown(item):
				result = False
			if isinstance(item, list):
				if not BigWorld.isKeyDown(item[0]) and not BigWorld.isKeyDown(item[1]):
					result = False
		return result
