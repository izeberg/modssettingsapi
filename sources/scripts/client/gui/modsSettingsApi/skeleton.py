
class IModsSettingsApiInternal(object):
	pass


class IModsSettingsApi(object):
	"""Public, can be shared with other mods"""
	def setModTemplate(self, linkage, template, callback, buttonHandler=None):
		""" Инициализация настроек
		:param linkage: Идентификатор настроек
		:param template: Шаблон настроек
		:param callback: Функция-обработчик новых настроек
		:param buttonHandler: Функция-обработчик нажатий на кнопку
		:return: Сохраненные настройки
		"""
		pass

	def registerCallback(self, linkage, callback, buttonHandler=None):
		""" Регистрация функций-обработчиков вызова
		:param linkage: Идентификатор настроек
		:param callback: Функция-обработчик новых настроек
		:param buttonHandler: Функция-обработчик нажатий на кнопку
		"""
		pass

	def getModSettings(self, linkage, template):
		""" Получение сохраненных настроек
		:param linkage: Идентификатор настроек
		:param template: Шаблон настроек
		:return: Сохраненные настройки, если таковых нет (либо есть, но устаревшие) - None
		"""
		pass

	def updateModSettings(self, linkage, newSettings):
		""" Изменение сохраненных настроек
		:param linkage: Идентификатор настроек
		:param newSettings: Новые настройки
		"""
		pass

	def checkKeySet(self, keyset):
		""" Проверка нажатия клавиш
		:param keyset: Набор клавиш для проверки
		:return: bool
		"""
		pass