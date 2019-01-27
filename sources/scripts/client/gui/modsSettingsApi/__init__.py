# coding: utf-8

__author__ = 'Iliev Renat'
__copyright__ = 'Copyright 2019, Wargaming'
__credits__ = ['Andruschyshyn Andrey', 'Iliev Renat']
__license__ = 'CC BY-NC-SA 4.0'
__version__ = '1.1.0'
__maintainer__ = 'Iliev Renat'
__email__ = 'mods@izeberg.ru'
__doc__ = 'https://wiki.wargaming.net/ru/ModsettingsAPI'

import Event
import collections

from gui.modsSettingsApi.api import ModsSettingsApi as ModsSettingsApiBase


__all__ = ('g_modsSettingsApi', )


class ModsSettingsApi(object):
	"""
	API доступа к меню настроек
	"""

	def __init__(self):
		self.__instance = ModsSettingsApiBase()

	def setModTemplate(self, linkage, template, callback, buttonHandler=None):
		""" Инициализация настроек
		:param linkage: Идентификатор настроек
		:param template: Шаблон настроек
		:param callback: Функция-обработчик новых настроек
		:param buttonHandler: Функция-обработчик нажатий на кнопку
		:return: Сохраненные настройки
		"""
		if isinstance(linkage, collections.Iterable):
			linkage = linkage[0]
		return self.__instance.setModTemplate(linkage, template, callback, buttonHandler)

	def registerCallback(self, linkage, callback, buttonHandler=None):
		""" Регистрация функций-обработчиков вызова
		:param linkage: Идентификатор настроек
		:param callback: Функция-обработчик новых настроек
		:param buttonHandler: Функция-обработчик нажатий на кнопку
		"""
		if isinstance(linkage, collections.Iterable):
			linkage = linkage[0]
		return self.__instance.registerCallback(linkage, callback, buttonHandler)

	def getModSettings(self, linkage, template=None):
		""" Получение сохраненных настроек
		:param linkage: Идентификатор настроек
		:param template: Шаблон настроек
		:return: Сохраненные настройки, если таковых нет - None
		"""
		if isinstance(linkage, collections.Iterable):
			linkage = linkage[0]
		return self.__instance.getModSettings(linkage, template)

	def updateModSettings(self, linkage, newSettings):
		""" Изменение сохраненных настроек
		:param linkage: Идентификатор настроек
		:param newSettings: Новые настройки
		"""
		if isinstance(linkage, collections.Iterable):
			linkage = linkage[0]
		return self.__instance.updateModSettings(linkage, newSettings)

	def checkKeySet(self, keyset):
		""" Проверка нажатия клавиш
		:param keyset: Набор клавиш для проверки
		:return: bool
		"""
		return self.__instance.checkKeySet(keyset)


g_modsSettingsApi = ModsSettingsApi()
