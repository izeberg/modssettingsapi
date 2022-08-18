# coding: utf-8

__author__ = 'Renat Iliev'
__copyright__ = 'Copyright 2022, Wargaming'
__credits__ = ['Andrii Andrushchyshyn', 'Renat Iliev']
__license__ = 'CC BY-NC-SA 4.0'
__maintainer__ = 'Renat Iliev'
__email__ = 'mods@izeberg.me'
__doc__ = 'https://wiki.wargaming.net/ru/ModsettingsAPI'

import Event

from helpers import dependency

from gui.modsSettingsApi.skeleton import IModsSettingsApi
from gui.modsSettingsApi.api import ModsSettingsApi
from gui.modsSettingsApi._constants import SPECIAL_KEYS
from gui.modsSettingsApi import templates


__all__ = ('g_modsSettingsApi', 'IModsSettingsApi', 'SPECIAL_KEYS', 'templates')


class _ModsSettingsApi(IModsSettingsApi):
	"""
	API доступа к меню настроек
	"""

	def __init__(self):
		super(_ModsSettingsApi, self).__init__()
		self.__instance = ModsSettingsApi()
		dependency._g_manager.addInstance(IModsSettingsApi, self)

	def saveModData(self, linkage, version, data):
		""" Сохранение данных мода
		:param linkage: Идентификатор
		:param version: Версия данных
		:param data: Данные для сохранения
		:return: Сохраненные настройки
		"""
		return self.__instance.saveModData(linkage, version, data)

	def getModData(self, linkage, version, default):
		""" Получение данных мода
		Eсли запрошенная версия не соответствует сохраненной, будут сохранены и возвращены стандартные данные
		:param linkage: Идентификатор
		:param version: Версия данных
		:param default: Стандартные данные
		:return: Сохраненные настройки
		"""
		return self.__instance.getModData(linkage, version, default)

	def setModTemplate(self, linkage, template, callback, buttonHandler=None):
		""" Инициализация настроек
		:param linkage: Идентификатор настроек
		:param template: Шаблон настроек
		:param callback: Функция-обработчик новых настроек
		:param buttonHandler: Функция-обработчик нажатий на кнопку
		:return: Сохраненные настройки
		"""
		return self.__instance.setModTemplate(linkage, template, callback, buttonHandler)

	def registerCallback(self, linkage, callback, buttonHandler=None):
		""" Регистрация функций-обработчиков вызова
		:param linkage: Идентификатор настроек
		:param callback: Функция-обработчик новых настроек
		:param buttonHandler: Функция-обработчик нажатий на кнопку
		"""
		return self.__instance.registerCallback(linkage, callback, buttonHandler)

	def getModSettings(self, linkage, template):
		""" Получение сохраненных настроек
		:param linkage: Идентификатор настроек
		:param template: Шаблон настроек
		:return: Сохраненные настройки, если таковых нет (либо есть, но устаревшие) - None
		"""
		return self.__instance.getModSettings(linkage, template)

	def updateModSettings(self, linkage, newSettings):
		""" Изменение сохраненных настроек
		:param linkage: Идентификатор настроек
		:param newSettings: Новые настройки
		"""
		return self.__instance.updateModSettings(linkage, newSettings)

	def checkKeySet(self, keyset):
		""" Проверка нажатия клавиш
		:param keyset: Набор клавиш для проверки
		:return: bool
		"""
		return self.__instance.checkKeySet(keyset)


g_modsSettingsApi = ModsSettingsApi()
