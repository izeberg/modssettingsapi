
import BigWorld
import game
import Keys
from gui.modsSettingsApi import g_modsSettingsApi, templates

modLinkage = 'test_iamspotted_templatesAPI'
modDataVersion = 1

template = {
	'modDisplayName': 'Мод «Я обнаружен» #2',
	'enabled': True,
	'column1': [
		templates.createCheckbox('Показать на миникарте квадрат засвета', 
								 'minimapClick', 
								 True, 
								 tooltip='{HEADER}Показать на миникарте квадрат засвета{/HEADER}{BODY}При вашем обнаружении мод автоматические кликнет на миникарте в квадрат где вы находитесь{/BODY}'),
		templates.createCheckbox('Сообщить в командный чат «Нужна помощь!»', 
								 'neadHelp', 
								 True, 
								 tooltip='{HEADER}Сообщить в командный чат «Нужна помощь!»{/HEADER}{BODY}При вашем обнаружении мод автоматические отправит команду «Нужна помощь!» вашим союзникам{/BODY}'),
		templates.createDropdown('Озвучка «Шестого чувства»', 'sixthSenseSound', 
								 ['Стандартная', 'Тихая', 'Громкая'], 0, 
								 tooltip='{HEADER}Озвучка «Шестого чувства»{/HEADER}{BODY}При срабатывании навыка «Шестого чувства» будет воспроизводиться один из нескольких вариантов озвучки.{/BODY}', 
								 button=templates.createButton(width=30, height=23, offsetTop=0, offsetLeft=0, 
															   icon='../maps/icons/buttons/sound.png', 
															   iconOffsetTop=0, iconOffsetLeft=1), 
								 width=200)
	],
	'column2': [
		templates.createSlider('Число живых союзников для активации мода', 
							   'aliveCounter', 
							   5, 1, 15, 1),
		templates.createCheckbox('Всегда оповещать о засвете при игре на артиллерии',
								 'alwaysOnArty', True,
								 tooltip='{HEADER}Всегда оповещать о засвете при игре на артиллерии{/HEADER}{BODY}Если вы вишли в бой на артилерии, мод будет всегда оповещать о вашем засвете независимо от выставленного лимита на число оставшехся в живих союзниках{/BODY}'),
		templates.createHotkey('Включение/отключение по кнопке',
							   'stateKeyset', [Keys.KEY_J],
							   tooltip='{HEADER}Включение/отключение по кнопке{/HEADER}{BODY}Активирует либо деактивирует модификацию при нажатии кнопки/комбинации кнопок{/BODY}'),
		templates.createNumericStepper('NumericStepper test',
									   'numStepperTest', 5,
									   1, 15, 0.1, 
									   tooltip='{HEADER}NumericStepper tooltip header{/HEADER}{BODY}NumericStepper tooltip body{/BODY}'),
		templates.createColorChoice('ColorChoice test',
									'colorChoice', '#ffffff',
									tooltip='{HEADER}ColorChoice tooltip header{/HEADER}{BODY}ColorChoice tooltip body{/BODY}'),
		templates.createRangeSlider('RangeSlider test',
									'rangeSlider', [20, 50], 0, 100, 1,
									50, 10, 50, '')
	]
}

settings = {
	'sixthSenseSound' : 0,
	'stateKeyset' : [Keys.KEY_J],
	'alwaysOnArty' : True,
	'neadHelp' : True,
	'enabled' : True,
	'minimapClick' : True,
	'aliveCounter' : 5,
	'numStepperTest' : 5,
	'colorChoice' : 'FFFFFF',
	'rangeSlider' : [20, 50],
}

def onModSettingsChanged(linkage, newSettings):    
	if linkage == modLinkage:
		print 'onModSettingsChanged', newSettings

def onButtonClicked(linkage, varName, value):    
	if linkage == modLinkage:
		clicks = g_modsSettingsApi.getModData(modLinkage, modDataVersion, 0)
		clicks += 1
		g_modsSettingsApi.saveModData(modLinkage, modDataVersion, clicks)

		print 'onButtonClicked', linkage, varName, value, clicks
	
def onGameKeyDown(event):
	if g_modsSettingsApi.checkKeyset(settings['stateKeyset']):
		print 'onHandleKeyEvent', settings['stateKeyset']

savedSettings = g_modsSettingsApi.getModSettings(modLinkage, template)
if savedSettings:
	settings = savedSettings
	g_modsSettingsApi.registerCallback(modLinkage, onModSettingsChanged, onButtonClicked)
else:
	settings = g_modsSettingsApi.setModTemplate(modLinkage, template, onModSettingsChanged, onButtonClicked)


