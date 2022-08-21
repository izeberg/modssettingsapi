from gui.modsSettingsApi._constants import COMPONENT_TYPE

def createBase(type, text, tooltip=None):
	""" Helper to create base component

	:param type: Component type, MUST be one of COMPONENT_TYPE
	:param text: Component text
	:param tooltip: Component tooltip, optional
	
	:return: Base component
	"""
	base = {
		'type': type,
		'text': text
	}
	if tooltip is not None:
		base['tooltip'] = tooltip
	return base

def createControl(type, text, varName, value, tooltip=None, button=None):
	""" Helper to create control component

	:param type: Component type, MUST be one of COMPONENT_TYPE
	:param text: Component text
	:param varName: Variable name bound to this component that will store component's value in onModSettingsChanged callback
	:param value: Component value
	:param tooltip: Component tooltip, optional
	:param button: Component button, optional
	
	:return: Control component
	"""
	control = createBase(type, text, tooltip)
	control.update({ 'varName': varName, 'value': value })
	if button is not None:
		control['button'] = button
	return control

def createOptionsControl(type, text, varName, options, value, tooltip=None, button=None):
	""" Helper to create control with options component

	:param type: Component type, MUST be one of COMPONENT_TYPE
	:param text: Component text
	:param varName: Variable name bound to this component that will store component's value in onModSettingsChanged callback
	:param options: List of string value for component options
	:type options: list or tuple of str
	:param value: Component value
	:param tooltip: Component tooltip, optional
	:param button: Component button, optional
	
	:return: Control component with options
	"""
	control = createControl(type, text, varName, value, tooltip, button)
	control['options'] = [{'label': option} for option in options]
	return control

def createStepper(type, text, varName, value, min, max, interval, tooltip=None, button=None):
	""" Helper to create stepper component (Slider, NumericStepper and RangeSlider)

	:param type: Component type, MUST be one of COMPONENT_TYPE
	:param text: Component text
	:param varName: Variable name bound to this component that will store component's value in onModSettingsChanged callback
	:param value: Component value
	:param min: Minimum value of stepper component
	:type min: int
	:param max: Maximum value of stepper component
	:type max: int
	:param interval: Step interval value
	:type interval: int
	:param tooltip: Component tooltip, optional
	:param button: Component button, optional
	
	:return: Stepper component
	"""
	stepper = createControl(type, text, varName, value, tooltip, button)
	stepper.update({ 'minimum': min, 'maximum': max, 'snapInterval': interval })
	return stepper

def createButton(width=None, height=None, text=None, offsetTop=None, offsetLeft=None, icon=None, iconOffsetTop=None, iconOffsetLeft=None):
	""" Helper to create button for component
	
	:param width: Button width, optional
	:param height: Button height, optional
	:param text: Button text content, optional
	:param offsetTop: Button top offset relatively to component, optional
	:param offsetLeft: Button left offset relatively to component, optional
	:param icon: Path to icon location, optional
	:param iconOffsetTop: Icon top offset relatively to button, optional
	:param iconOffsetLeft: Icon left offset relatively to button, optional

	:return: Component button
	"""
	button = {}
	if width is not None:
		button['width'] = width
	if height is not None:
		button['height'] = height
	if text is not None:
		button['text'] = text
	if offsetTop is not None:
		button['offsetTop'] = offsetTop
	if offsetLeft is not None:
		button['offsetLeft'] = offsetLeft
	if icon is not None and text is None:
		button['iconSource'] = icon
	if iconOffsetTop is not None:
		button['iconOffsetTop'] = iconOffsetTop
	if iconOffsetLeft is not None:
		button['iconOffsetLeft'] = iconOffsetLeft
	return button

def createEmpty():
	""" Helper to create empty component
	
	:return: Empty component
	"""
	return { 
		'type': 'Empty' 
	}

def createLabel(text, tooltip=None):
	""" Helper to create Label component

	:param text: Component text
	:param tooltip: Component tooltip, optional

	:return: Label component
	"""
	return createBase(COMPONENT_TYPE.LABEL, text, tooltip)

def createCheckbox(text, varName, value, tooltip=None, button=None):
	""" Helper to create Checkbox component

	:param text: Component text
	:param varName: Variable name bound to this component that will store component's value in onModSettingsChanged callback
	:param value: Component value
	:type value: bool
	:param tooltip: Component tooltip, optional
	:param button: Component button, optional

	:return: Checkbox component
	"""
	return createControl(COMPONENT_TYPE.CHECKBOX, text, varName, value, tooltip, button)

def createRadioButtonGroup(text, varName, options, value, tooltip=None, button=None):
	""" Helper to create RadioButtonGroup component

	:param text: Component text
	:param varName: Variable name bound to this component that will store component's value in onModSettingsChanged callback
	:param value: Component value, index of options
	:type value: int
	:param tooltip: Component tooltip, optional
	:param button: Component button, optional

	:return: RadioButtonGroup component
	"""
	return createOptionsControl(COMPONENT_TYPE.RADIO_BUTTON_GROUP, text, varName, options, value, tooltip, button)

def createDropdown(text, varName, options, value, tooltip=None, button=None, width=None):
	""" Helper to create Dropdown component

	:param text: Component text
	:param varName: Variable name bound to this component that will store component's value in onModSettingsChanged callback
	:param value: Component value, index of options
	:type value: int
	:param tooltip: Component tooltip, optional
	:param button: Component button, optional
	:param width: Component width, optional

	:return: Dropdown component
	"""
	control = createOptionsControl(COMPONENT_TYPE.DROPDOWN, text, varName, options, value, tooltip, button)
	if width is not None:
		control['width'] = width
	return control

def createSlider(text, varName, value, min, max, interval, format='{{value}}', tooltip=None, button=None, width=None):
	""" Helper to create Slider component

	:param text: Component text
	:param varName: Variable name bound to this component that will store component's value in onModSettingsChanged callback
	:param value: Component value
	:type value: int
	:param min: Minimum value of stepper component
	:type min: int
	:param max: Maximum value of stepper component
	:type max: int
	:param interval: Step interval value
	:type interval: int
	:param format: Component value format template, defaults to '{{value}}' optional
	:param tooltip: Component tooltip, optional
	:param button: Component button, optional
	:param width: Component width, optional

	:return: Slider component
	"""
	stepper = createStepper(COMPONENT_TYPE.SLIDER, text, varName, value, min, max, interval, tooltip, button)
	stepper['format'] = format
	if width is not None:
		stepper['width'] = width
	return stepper

def createInput(text, varName, value, tooltip=None, button=None, width=None):
	""" Helper to create Input component

	:param text: Component text
	:param varName: Variable name bound to this component that will store component's value in onModSettingsChanged callback
	:param value: Component value
	:type value: str
	:param tooltip: Component tooltip, optional
	:param button: Component button, optional
	:param width: Component width, optional

	:return: Input component
	"""
	control = createControl(COMPONENT_TYPE.TEXT_INPUT, text, varName, value, tooltip, button)
	if width is not None:
		control['width'] = width
	return control

def createNumericStepper(text, varName, value, min, max, interval, tooltip=None, button=None, manual=False):
	""" Helper to create NumericStepper component

	:param text: Component text
	:param varName: Variable name bound to this component that will store component's value in onModSettingsChanged callback
	:param value: Component value
	:type value: int
	:param min: Minimum value of stepper component
	:type min: int
	:param max: Maximum value of stepper component
	:type max: int
	:param interval: Step interval value
	:type interval: int
	:param tooltip: Component tooltip, optional
	:param button: Component button, optional
	:param manual: Defines if user can manually type value, optional

	:return: NumericStepper component
	"""
	stepper = createStepper(COMPONENT_TYPE.NUMERIC_STEPPER, text, varName, value, min, max, interval, tooltip, button)
	stepper['canManualInput'] = manual
	return stepper

def createHotkey(text, varName, value, tooltip=None, button=None):
	""" Helper to create Hotkey component

	:param text: Component text
	:param varName: Variable name bound to this component that will store component's value in onModSettingsChanged callback
	:param value: Component value
	:type value: list of BigWorld keys
	:param tooltip: Component tooltip, optional
	:param button: Component button, optional

	:return: Hotkey component
	"""
	return createControl(COMPONENT_TYPE.HOTKEY, text, varName, value, tooltip, button)

def createColorChoice(text, varName, value, tooltip=None, button=None):
	""" Helper to create Hotkey component

	:param text: Component text
	:param varName: Variable name bound to this component that will store component's value in onModSettingsChanged callback
	:param value: Component value
	:type value: str of hex color code with or without hash
	:param tooltip: Component tooltip, optional
	:param button: Component button, optional

	:return: Hotkey component
	"""
	if value.startswith('#'):
		value = value.lstrip('#')
	return createControl(COMPONENT_TYPE.COLOR_CHOICE, text, varName, value, tooltip, button)

def createRangeSlider(text, varName, value, min, max, interval, step, minRange, labelStep, labelPostfix, tooltip=None, button=None):
	""" Helper to create RangeSlider component

	:param text: Component text
	:param varName: Variable name bound to this component that will store component's value in onModSettingsChanged callback
	:param value: Component value
	:type value: list[int, int]
	:param min: Minimum value of stepper component
	:type min: int
	:param max: Maximum value of stepper component
	:type max: int
	:param interval: Step interval value
	:type interval: int
	:param step: Step
	:param minRange: Minimal range of values
	:param minRange: int
	:param labelStep: Steps of component labels
	:param labelStep: int
	:param labelPostfix: Postfix of component labels
	:param labelPostfix: str
	:param tooltip: Component tooltip, optional
	:param button: Component button, optional

	:return: RangeSlider component
	"""
	stepper = createStepper(COMPONENT_TYPE.RANGE_SLIDER, text, varName, value, min, max, interval, tooltip, button)
	stepper.update({
		'divisionStep': step,
		'minRangeDistance': minRange,
		'divisionLabelStep': labelStep,
		'divisionLabelPostfix': labelPostfix,
	})
	return stepper
