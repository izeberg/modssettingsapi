
import BigWorld
import game
import Keys
from gui.modsSettingsApi import g_modsSettingsApi

modLinkage = 'test_iamspotted'

template  = {
	'modDisplayName': 'Мод «Я обнаружен»',
	'settingsVersion': 0,
	'enabled': True,
	'column1': [
		{
			'type': 'CheckBox',
			'text': 'Показать на миникарте квадрат засвета',
			'value': True,
			'tooltip': '{HEADER}Показать на миникарте квадрат засвета{/HEADER}{BODY}При вашем обнаружении мод автоматические кликнет на миникарте в квадрат где вы находитесь{/BODY}',
			'varName': 'minimapClick'
		},
		{
			'type': 'CheckBox',
			'text': 'Сообщить в командный чат «Нужна помощь!»',
			'value': True,
			'tooltip': '{HEADER}Сообщить в командный чат «Нужна помощь!»{/HEADER}{BODY}При вашем обнаружении мод автоматические отправит команду «Нужна помощь!» вашим союзникам{/BODY}',
			'varName': 'neadHelp'
		},
		{
			'type': 'Dropdown',
			'text': 'Озвучка «Шестого чувства»',
			'tooltip': '{HEADER}Озвучка «Шестого чувства»{/HEADER}{BODY}При срабатывании навыка «Шестого чувства» будет воспроизводиться один из нескольких вариантов озвучки.{/BODY}',
			'options':  [
				{ 'label': 'Стандартная' },
				{ 'label': 'Тихая' },
				{ 'label': 'Громкая' }
			],
			'button': {
				'width': 30,
				'height': 23,
				'offsetTop': 0,
				'offsetLeft': 0,
				'iconSource': '../maps/icons/buttons/sound.png',
				'iconOffsetTop': 0,
				'iconOffsetLeft': 1,
			},
			'width': 200,
			'value': 0,
			'varName': 'sixthSenseSound'
		}
	],
		
	'column2': [
		{
			'type': 'Slider',
			'text': 'Число живых союзников для активации мода',
			'minimum': 1,
			'maximum': 15,
			'snapInterval': 1,
			'value': 5,
			'format': '{{value}}',
			'varName': 'aliveCounter'
		},
		{
			'type': 'CheckBox',
			'text': 'Всегда оповещать о засвете при игре на артиллерии',
			'tooltip': '{HEADER}Всегда оповещать о засвете при игре на артиллерии{/HEADER}{BODY}Если вы вишли в бой на артилерии, мод будет всегда оповещать о вашем засвете независимо от выставленного лимита на число оставшехся в живих союзниках{/BODY}',
			'value': True,
			'varName': 'alwaysOnArty'
		},
		{
			'type': 'HotKey',
			'text': 'Включение/отключение по кнопке',
			'tooltip': '{HEADER}Включение/отключение по кнопке{/HEADER}{BODY}Активирует либо деактивирует модификацию при нажатии кнопки/комбинации кнопок{/BODY}',
			'value': [Keys.KEY_J],
			'varName': 'stateKeySet'          
		},
		{
			'type': 'NumericStepper',
			'header': 'NumericStepper test',
			'tooltip': '{HEADER}NumericStepper tooltip header{/HEADER}{BODY}NumericStepper tooltip body{/BODY}',
			'minimum': 1,
			'maximum': 15,
			'snapInterval': 0.1,
			'value': 5,
			'varName': 'numStepperTest'
		},
	]
}

settings = {
	'sixthSenseSound' : 0,
	'stateKeySet' : [Keys.KEY_J],
	'alwaysOnArty' : True,
	'neadHelp' : True,
	'enabled' : True,
	'minimapClick' : True,
	'aliveCounter' : 5,
	'numStepperTest' : 5,
}

def onModSettingsChanged(linkage, newSettings):    
	if linkage == modLinkage:
		print 'onModSettingsChanged', newSettings

def onButtonClicked(linkage, varName, value):    
	if linkage == modLinkage:
		print 'onButtonClicked', linkage, varName, value
	
def onGameKeyDown(event):
	if g_modsSettingsApi.checkKeySet(settings['stateKeySet']):
		print 'onHandleKeyEvent', settings['stateKeySet']

savedSettings = g_modsSettingsApi.getModSettings((modLinkage, ), template)
if savedSettings:
	settings = savedSettings
	g_modsSettingsApi.registerCallback((modLinkage, ), onModSettingsChanged, onButtonClicked)
else:
	settings = g_modsSettingsApi.setModTemplate((modLinkage, ), template, onModSettingsChanged, onButtonClicked)   


