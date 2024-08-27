from helpers import getClientLanguage

from ._constants import *
from .utils import memoize, listVFSDir, readLocalization


class Localization(object):

	def __init__(self):
		self.__data = {}
		self.__languages = []

		self.__getLanguages()
		self.__readLocalizations()

	def __getLanguages(self):
		clientLanguage = getClientLanguage()
		availableLanguages = self.__getAvailableLanguages()
		language = DEFAULT_UI_LANGUAGE
		fallbackLanguage = DEFAULT_UI_LANGUAGE
		if clientLanguage in CIS_LANGUAGES:
			fallbackLanguage = DEFAULT_CIS_UI_LANGUAGE
		if clientLanguage in availableLanguages:
			language = clientLanguage
		elif fallbackLanguage in availableLanguages:
			language = fallbackLanguage
		for language in (language, fallbackLanguage, DEFAULT_UI_LANGUAGE):
			if language not in self.__languages:
				self.__languages.append(language)

	def __getAvailableLanguages(self):
		result = []
		listing = listVFSDir(L10N_VFS_ROOT)
		for entry in listing:
			if '.yml' not in entry:
				continue
			language = entry.replace('.yml', '')
			result.append(language)
		return result

	def __readLocalizations(self):
		for langauge in self.__languages:
			path = L10N_FILE_MASK % langauge
			l10nData = readLocalization(path)
			if l10nData:
				self.__data[langauge] = l10nData

	@memoize
	def __call__(self, key):
		for language in self.__languages:
			if key in self.__data[language]:
				return self.__data[language][key]
		return key

	@memoize
	def pack(self):
		result = {}
		for language in reversed(self.__languages):
			for key, value in self.__data[language].iteritems():
				result[key] = value
		return result

l10n = Localization()
