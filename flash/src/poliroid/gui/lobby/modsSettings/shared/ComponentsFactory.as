package poliroid.gui.lobby.modsSettings.shared
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	import scaleform.clik.controls.ButtonGroup;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.IndexEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.events.SliderEvent;
	import net.wg.gui.components.controls.ButtonIconNormal;
	import net.wg.gui.components.controls.CheckBox;
	import net.wg.gui.components.controls.DropdownMenu;
	import net.wg.gui.components.controls.HyperLink;
	import net.wg.gui.components.controls.InfoIcon;
	import net.wg.gui.components.controls.LabelControl;
	import net.wg.gui.components.controls.NumericStepper;
	import net.wg.gui.components.controls.RadioButton;
	import net.wg.gui.components.controls.RangeSlider;
	import net.wg.gui.components.controls.Slider;
	import net.wg.gui.components.controls.SoundButtonEx;
	import net.wg.gui.components.controls.StepSlider;
	import net.wg.gui.components.controls.TextInput;
	import poliroid.gui.lobby.modsSettings.controls.ColorChoiceButton;
	import poliroid.gui.lobby.modsSettings.controls.HotkeyControl;
	import poliroid.gui.lobby.modsSettings.events.InteractiveEvent;
	import poliroid.gui.lobby.modsSettings.shared.Utilities;

	public class ComponentsFactory
	{
		private static const SCROLL_ITEM_LIMIT:int = 9;

		public function ComponentsFactory()
		{
			super();
		}

		public static function handleComponentEvent(event:Event):void
		{
			event.target.dispatchEvent(new InteractiveEvent(InteractiveEvent.VALUE_CHANGED));
		}

		public static function createEmpty(width:Number, height:Number):MovieClip
		{
			var mc:MovieClip = new MovieClip();

			mc.width = width;
			mc.height = height ? height : Constants.EMPTY_COMPONENT_HEIGHT;

			return mc;
		}

		public static function createLabel(text:String, tooltip:String = '', tooltipIcon:String = ''):DisplayObject
		{
			var ui:UIComponent = new UIComponent();
			var label:LabelControl = LabelControl(App.utils.classFactory.getComponent('LabelControl', LabelControl));

			label.width = 800;
			label.htmlText = text;

			if (tooltip)
			{
				label.toolTip = tooltip;
				label.infoIcoType = tooltipIcon ? tooltipIcon : InfoIcon.TYPE_INFO;
			}

			ui.addChild(label);
			label.validateNow();

			// Add pointer cursor to tooltip icon if available
			var infoIcon:InfoIcon = label['_infoIco'];

			if (infoIcon)
				infoIcon.buttonMode = true;

			var result:MovieClip = new MovieClip();

			result.addChild(ui);
			result['label'] = label;

			return result;
		}

		public static function createLink(config:Object, linkage:String, text:String, url:String):DisplayObject
		{
			var ui:UIComponent = new UIComponent();
			var link:HyperLink = HyperLink(App.utils.classFactory.getComponent('HyperLinkUI', HyperLink));

			link.label = text;
			link.autoSize = TextFieldAutoSize.LEFT;
			link.isShowLinkIco = true;
			link.addEventListener(ButtonEvent.CLICK, function():void {
				link.dispatchEvent(new InteractiveEvent(InteractiveEvent.LINK_CLICK, linkage, config.id, url));
			});
			ui.addChild(link);

			var result:MovieClip = new MovieClip();

			result.addChild(ui);

			return result;
		}

		public static function createCheckBox(config:Object, linkage:String, text:String, value:Boolean, tooltip:String = '', tooltipIcon:String = ''):DisplayObject
		{
			var ui:UIComponent = new UIComponent();
			var checkbox:CheckBox = CheckBox(App.utils.classFactory.getComponent('CheckBox', CheckBox));

			checkbox.label = text;
			checkbox.selected = value;
			if (tooltip)
			{
				checkbox.toolTip = tooltip;
				checkbox.infoIcoType = tooltipIcon ? tooltipIcon : InfoIcon.TYPE_INFO;
			}
			checkbox.width = 800;
			ui.addChild(checkbox);
			checkbox.validateNow();

			// Add pointer cursor to tooltip icon if available
			var infoIcon:InfoIcon = checkbox['_infoIco'];

			if (infoIcon)
				infoIcon.buttonMode = true;

			checkbox.addEventListener(Event.SELECT, handleComponentEvent);

			if (config.hasOwnProperty('button'))
			{
				var positionY:Number = checkbox.y + Constants.MOD_MARGIN_BOTTOM - 3;
				var positionX:Number = checkbox.x + checkbox.textField.textWidth + Constants.BUTTON_MARGIN_LEFT + 20;

				if (tooltip)
					positionX += 25;

				var button:DisplayObject = createDynamicButton(config, positionX, positionY);

				button.addEventListener(ButtonEvent.CLICK, function():void {
					button.dispatchEvent(new InteractiveEvent(InteractiveEvent.BUTTON_CLICK, linkage, config.varName, checkbox.selected));
				});

				ui.addChild(button);
			}

			var result:MovieClip = new MovieClip();

			result.addChild(ui);
			result[Constants.COMPONENT_RETURN_VALUE_KEY] = new ValueProxy(checkbox, 'selected');

			return result;
		}

		public static function createRadioButtonGroup(config:Object, linkage:String, groupName:String, options:Array, text:String = '', tooltip:String = '', tooltipIcon:String = '', value:Number = 0):DisplayObject
		{
			var ui:UIComponent = new UIComponent();
			var margin:Number = text ? Constants.COMPONENT_HEADER_MARGIN : 0;

			if (text)
			{
				var label:DisplayObject = ComponentsFactory.createLabel(text, tooltip, tooltipIcon);

				label.x = label.y = 0;
				ui.addChild(label);
			}

			var buttonGroup:ButtonGroup = ButtonGroup.getGroup(groupName, ui);

			for (var i:Number = 0; i < options.length; i++)
			{
				var radioButton:RadioButton = RadioButton(App.utils.classFactory.getComponent('RadioButton', RadioButton));

				radioButton.y = i * Constants.RADIO_BUTTONS_MARGIN + margin;
				radioButton.label = options[i].label;
				radioButton.autoSize = TextFieldAutoSize.LEFT;

				ui.addChild(radioButton);
				buttonGroup.addButton(radioButton);

				radioButton.addEventListener(MouseEvent.CLICK, handleComponentEvent);
			}

			buttonGroup.setSelectedButtonByIndex(value);

			if (config.hasOwnProperty('button'))
			{
				var positionX:Number = 0;
				var positionY:Number = 0;
				radioButton = RadioButton(buttonGroup.getButtonAt(0));

				if (text)
				{
					positionX = label.x + label['label'].textField.textWidth + Constants.BUTTON_MARGIN_LEFT;

					if (tooltip)
						positionX += 25;
				}
				else
					positionX = radioButton.x + radioButton.width + Constants.BUTTON_MARGIN_LEFT;

				var button:DisplayObject = createDynamicButton(config, positionX, positionY);

				button.addEventListener(ButtonEvent.CLICK, function():void {
					button.dispatchEvent(new InteractiveEvent(InteractiveEvent.BUTTON_CLICK, linkage, config.varName, buttonGroup.selectedIndex));
				});

				ui.addChild(button);
			}

			var result:MovieClip = new MovieClip();

			result.addChild(ui);
			result[Constants.COMPONENT_RETURN_VALUE_KEY] = new ValueProxy(buttonGroup, 'selectedIndex');

			return result;
		}

		public static function createDropdown(config:Object, linkage:String, options:Array, text:String = '', tooltip:String = '', tooltipIcon:String = '', value:Number = 0):DisplayObject
		{
			var ui:UIComponent = new UIComponent();
			var margin:Number = text ? Constants.COMPONENT_HEADER_MARGIN : 0;

			if (text)
			{
				var label:DisplayObject = ComponentsFactory.createLabel(text, tooltip, tooltipIcon);

				label.x = label.y = 0;
				ui.addChild(label);
			}

			var dropdown:DropdownMenu = DropdownMenu(App.utils.classFactory.getObject('DropdownMenuUI'));

			dropdown.y = margin;
			dropdown.width = config.hasOwnProperty('width') ? config.width : 200;

			if (options.length > SCROLL_ITEM_LIMIT)
			{
				dropdown['componentInspectorSetting'] = true;
				dropdown.scrollBar = 'ScrollBar';
				dropdown.rowCount = SCROLL_ITEM_LIMIT;
				dropdown.inspectableThumbOffset = {'top': 0, 'bottom': 0};
				dropdown['componentInspectorSetting'] = false;
			}
			else
			{
				dropdown.rowCount = options.length;
				dropdown.scrollBar = '';
			}

			dropdown.itemRenderer = App.utils.classFactory.getClass('DropDownListItemRendererSound');
			dropdown.dropdown = 'DropdownMenu_ScrollingList';
			dropdown.dataProvider = new DataProvider(options);
			dropdown.selectedIndex = value;
			dropdown.validateNow();

			ui.addChild(dropdown);

			dropdown.handleScroll = false;
			dropdown.addEventListener(ListEvent.INDEX_CHANGE, handleComponentEvent);
			dropdown['componentInspectorSetting'] = true;
			dropdown.inspectableMenuOffset = {'top': -5, 'right': -6, 'bottom': 0, 'left': 3};
			dropdown['componentInspectorSetting'] = false;

			if (config.hasOwnProperty('button'))
			{
				var positionY:Number = dropdown.y + Constants.MOD_MARGIN_BOTTOM - 3;
				var positionX:Number = dropdown.x + dropdown.width + Constants.BUTTON_MARGIN_LEFT;
				var button:DisplayObject = createDynamicButton(config, positionX, positionY);

				button.addEventListener(ButtonEvent.CLICK, function():void {
					button.dispatchEvent(new InteractiveEvent(InteractiveEvent.BUTTON_CLICK, linkage, config.varName, dropdown.selectedIndex));
				});

				ui.addChild(button);
			}

			var result:MovieClip = new MovieClip();

			result.addChild(ui);
			result[Constants.COMPONENT_RETURN_VALUE_KEY] = new ValueProxy(dropdown, 'selectedIndex');

			return result;
		}

		public static function createSlider(config:Object, linkage:String, min:Number, max:Number, interval:Number, value:Number, format:String, text:String = '', tooltip:String = '', tooltipIcon:String = ''):DisplayObject
		{
			var ui:UIComponent = new UIComponent();
			var margin:Number = text ? Constants.COMPONENT_HEADER_MARGIN : 0;

			if (text)
			{
				var label:DisplayObject = ComponentsFactory.createLabel(text, tooltip, tooltipIcon);

				label.x = label.y = 0;
				ui.addChild(label);
			}

			var slider:Slider = Slider(App.utils.classFactory.getComponent('Slider', Slider));

			slider.y = margin;
			slider.width = config.hasOwnProperty('width') ? config.width : 200;
			slider.minimum = min;
			slider.maximum = max;
			slider.snapInterval = interval;
			slider.snapping = true;
			slider.value = value;

			ui.addChild(slider);

			slider.addEventListener(SliderEvent.VALUE_CHANGE, handleComponentEvent);

			if (format)
			{
				var formattedString:String = Utilities.getFormattedSliderValue(format, slider.value.toString());
				var valueLabel:DisplayObject = ComponentsFactory.createLabel(formattedString, '');

				valueLabel.y = slider.y + 2;
				valueLabel.x = slider.x + slider.width + Constants.SLIDER_VALUE_MARGIN;

				ui.addChild(valueLabel);

				slider.addEventListener(SliderEvent.VALUE_CHANGE, function(event:SliderEvent):void {
					valueLabel['label'].htmlText = Utilities.getFormattedSliderValue(format, event.value.toString());
				});
			}

			if (config.hasOwnProperty('button'))
			{
				var positionY:Number = margin;
				var positionX:Number = slider.x + slider.width + Constants.SLIDER_VALUE_MARGIN + 15;

				if (format)
					positionX += 15;

				var button:DisplayObject = createDynamicButton(config, positionX, positionY);

				button.addEventListener(ButtonEvent.CLICK, function():void {
					button.dispatchEvent(new InteractiveEvent(InteractiveEvent.BUTTON_CLICK, linkage, config.varName, slider.value));
				});

				ui.addChild(button);
			}

			slider.addEventListener(MouseEvent.MOUSE_WHEEL, function(event:MouseEvent):void {
				event.stopImmediatePropagation();
				result.parent.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_WHEEL, event.bubbles, event.cancelable, event.localX, event.localY, event.relatedObject, event.ctrlKey, event.altKey, event.shiftKey, event.buttonDown, event.delta));
			});

			var result:MovieClip = new MovieClip();

			result.addChild(ui);
			result[Constants.COMPONENT_RETURN_VALUE_KEY] = new ValueProxy(slider, 'value');

			return result;
		}

		public static function createStepSlider(config:Object, linkage:String, options:Array, format:String, text:String = '', tooltip:String = '', tooltipIcon:String = '', selectedIndex:Number = 0):DisplayObject
		{
			var ui:UIComponent = new UIComponent();
			var margin:Number = text ? Constants.COMPONENT_HEADER_MARGIN : 0;

			if (text)
			{
				var label:DisplayObject = ComponentsFactory.createLabel(text, tooltip, tooltipIcon);

				label.x = label.y = 0;
				ui.addChild(label);
			}

			var stepSlider:StepSlider = StepSlider(App.utils.classFactory.getComponent('StepSliderUI', StepSlider));

			stepSlider.y = margin;
			stepSlider.width = config.hasOwnProperty('width') ? config.width : 200;
			stepSlider.dataProvider = new DataProvider(options);
			stepSlider.value = selectedIndex;

			ui.addChild(stepSlider);

			stepSlider.addEventListener(SliderEvent.VALUE_CHANGE, handleComponentEvent);

			var itemLabel:String = stepSlider['getItemLabel'](stepSlider.dataProvider.requestItemAt(stepSlider.value));
			var formattedItemLabel:String = Utilities.getFormattedSliderValue(format, itemLabel);
			var valueLabel:DisplayObject = ComponentsFactory.createLabel(formattedItemLabel, '');

			valueLabel.y = stepSlider.y + 2;
			valueLabel.x = stepSlider.x + stepSlider.width + Constants.SLIDER_VALUE_MARGIN;

			ui.addChild(valueLabel);

			stepSlider.addEventListener(SliderEvent.VALUE_CHANGE, function(event:SliderEvent):void {
				var itemLabel:String = stepSlider['getItemLabel'](stepSlider.dataProvider.requestItemAt(event.value));
				valueLabel['label'].htmlText = Utilities.getFormattedSliderValue(format, itemLabel);
			});

			if (config.hasOwnProperty('button'))
			{
				var positionY:Number = margin;
				var positionX:Number = stepSlider.x + stepSlider.width + Constants.SLIDER_VALUE_MARGIN + 15;

				if (format)
					positionX += 15;

				var button:DisplayObject = createDynamicButton(config, positionX, positionY);

				button.addEventListener(ButtonEvent.CLICK, function(event:ButtonEvent):void {
					button.dispatchEvent(new InteractiveEvent(InteractiveEvent.BUTTON_CLICK, linkage, config.varName, stepSlider.value));
				});

				ui.addChild(button);
			}

			stepSlider.addEventListener(MouseEvent.MOUSE_WHEEL, function(event:MouseEvent):void {
				event.stopImmediatePropagation();
				result.parent.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_WHEEL, event.bubbles, event.cancelable, event.localX, event.localY, event.relatedObject, event.ctrlKey, event.altKey, event.shiftKey, event.buttonDown, event.delta));
			});

			var result:MovieClip = new MovieClip();

			result.addChild(ui);
			result[Constants.COMPONENT_RETURN_VALUE_KEY] = new ValueProxy(stepSlider, 'value');

			return result;
		}

		public static function createTextInput(config:Object, text:String = '', tooltip:String = '', tooltipIcon:String = '', value:String = ''):DisplayObject
		{
			var ui:UIComponent = new UIComponent();
			var margin:Number = text ? Constants.COMPONENT_HEADER_MARGIN : 0;

			if (text)
			{
				var label:DisplayObject = ComponentsFactory.createLabel(text, tooltip, tooltipIcon);

				label.x = label.y = 0;

				ui.addChild(label);
			}

			var textInput:TextInput = TextInput(App.utils.classFactory.getComponent('TextInput', TextInput));

			textInput.y = margin;
			textInput.width = config.hasOwnProperty('width') ? config.width : 200;
			textInput.text = value;
			textInput.validateNow();

			ui.addChild(textInput);

			textInput.addEventListener(InputEvent.INPUT, handleComponentEvent);

			var result:MovieClip = new MovieClip();

			result.addChild(ui);
			result[Constants.COMPONENT_RETURN_VALUE_KEY] = new ValueProxy(textInput, 'text');

			return result;
		}

		public static function createNumericStepper(config:Object, linkage:String, minimum:Number, maximum:Number, stepSize:Number, value:Number, text:String, tooltip:String, tooltipIcon:String):DisplayObject
		{
			var ui:UIComponent = new UIComponent();

			if (text)
			{
				var label = ComponentsFactory.createLabel(text, tooltip, tooltipIcon);

				label.y = 4;
				ui.addChild(label);
			}

			var numericStepper:NumericStepper = NumericStepper(App.utils.classFactory.getComponent('NumericStepper', NumericStepper));

			numericStepper.x = 315;
			if (config.hasOwnProperty('canManualInput'))
				numericStepper.canManualInput = config.canManualInput;
			numericStepper.minimum = minimum;
			numericStepper.maximum = maximum;
			numericStepper.stepSize = stepSize;
			numericStepper.value = value;
			numericStepper.validateNow();

			ui.addChild(numericStepper);

			numericStepper.addEventListener(IndexEvent.INDEX_CHANGE, handleComponentEvent);

			var result:MovieClip = new MovieClip();

			result.addChild(ui);
			result[Constants.COMPONENT_RETURN_VALUE_KEY] = new ValueProxy(numericStepper, 'value');

			return result;
		}

		public static function createHotKey(config:Object, linkage:String, value:Array, text:String = '', tooltip:String = '', tooltipIcon:String = ''):DisplayObject
		{
			var ui:UIComponent = new UIComponent();
			var label:DisplayObject = ComponentsFactory.createLabel(text, tooltip, tooltipIcon);

			label.x = 0;
			label.y = 4;
			ui.addChild(label);

			var hotkeyCtrl:HotkeyControl = App.utils.classFactory.getComponent('HotkeyControlUI', HotkeyControl);

			hotkeyCtrl.x = 315;
			hotkeyCtrl.y = 0;

			ui.addChild(hotkeyCtrl);

			var result:MovieClip = new MovieClip();

			result.addChild(ui);
			result[Constants.COMPONENT_RETURN_VALUE_KEY] = new ValueProxy(hotkeyCtrl, 'keyset');
			result['control'] = hotkeyCtrl;

			return result;
		}

		public static function createColorChoice(config:Object, linkage:String, value:String, text:String = '', tooltip:String = '', tooltipIcon:String = ''):DisplayObject
		{
			var ui:UIComponent = new UIComponent();
			var label:DisplayObject = ComponentsFactory.createLabel(text, tooltip, tooltipIcon);

			label.x = 0;
			label.y = 4;
			ui.addChild(label);

			var colorChoice:ColorChoiceButton = App.utils.classFactory.getComponent('ColorChoiceButtonUI', ColorChoiceButton);

			colorChoice.x = 315;
			colorChoice.y = 0;
			colorChoice.color = value;

			ui.addChild(colorChoice);

			var result:MovieClip = new MovieClip();

			result.addChild(ui);
			result[Constants.COMPONENT_RETURN_VALUE_KEY] = new ValueProxy(colorChoice, 'color');

			return result;
		}

		public static function createRangeSlider(config:Object, linkage:String):DisplayObject
		{
			var ui:UIComponent = new UIComponent();
			var label:DisplayObject = ComponentsFactory.createLabel(config.text, config.tooltip, config.tooltipIcon);

			label.y = -7;
			label.x = 0;
			ui.y += 7;
			ui.addChild(label);

			var rangeSlider:RangeSlider = RangeSlider(App.utils.classFactory.getComponent('RangeSliderUI', RangeSlider));

			rangeSlider.y += 33;
			rangeSlider.x += 5;
			rangeSlider.width = 240;
			rangeSlider.maximum = config.maximum;
			rangeSlider.minimum = config.minimum;
			rangeSlider.divisionLabelPostfix = config.divisionLabelPostfix;
			rangeSlider.divisionLabelStep = config.divisionLabelStep;
			rangeSlider.divisionStep = config.divisionStep;
			rangeSlider.minRangeDistance = config.minRangeDistance;
			rangeSlider.snapInterval = config.snapInterval;
			rangeSlider.leftValue = config.value[0];
			rangeSlider.rightValue = config.value[1];
			rangeSlider.focusable = true;
			rangeSlider.snapping = true;
			rangeSlider.rangeMode = true;
			rangeSlider['valueProxyValue'] = [rangeSlider.leftValue, rangeSlider.rightValue];

			var valueLabel:DisplayObject = ComponentsFactory.createLabel('', '');

			valueLabel.y = rangeSlider.y + 2;
			valueLabel.x = rangeSlider.x + rangeSlider.width + Constants.SLIDER_VALUE_MARGIN + 5;
			valueLabel['label'].htmlText = rangeSlider.leftValue + ' / ' + rangeSlider.rightValue;

			ui.addChild(valueLabel);

			rangeSlider.addEventListener(SliderEvent.VALUE_CHANGE, function(event:SliderEvent):void {
				valueLabel['label'].htmlText = rangeSlider.leftValue + ' / ' + rangeSlider.rightValue;
				rangeSlider['valueProxyValue'] = [rangeSlider.leftValue, rangeSlider.rightValue];
				handleComponentEvent(event);
			});
			rangeSlider.validateNow();

			ui.addChild(rangeSlider);

			var result:MovieClip = new MovieClip();

			result.addChild(ui);
			result[Constants.COMPONENT_RETURN_VALUE_KEY] = new ValueProxy(rangeSlider, 'valueProxyValue');

			return result;
		}

		private static function createDynamicButton(config:Object, positionX:Number = 0, positionY:Number = 0):DisplayObject
		{
			var button:*;

			if (config.button.hasOwnProperty('text') && config.button.text != '')
			{
				button = SoundButtonEx(App.utils.classFactory.getComponent('ButtonNormal', SoundButtonEx));
				button.label = config.button.text;
			}

			if (config.button.hasOwnProperty('iconSource') && config.button.iconSource != '')
			{
				button = ButtonIconNormal(App.utils.classFactory.getComponent('ButtonIconNormalUI', ButtonIconNormal));
				button.iconSource = config.button.iconSource;
				button.iconOffsetTop = config.button.hasOwnProperty('iconOffsetTop') ? config.button.iconOffsetTop : 0;
				button.iconOffsetLeft = config.button.hasOwnProperty('iconOffsetLeft') ? config.button.iconOffsetLeft : 0;
			}

			button.x = positionX;
			button.y = positionY;

			if (config.button.hasOwnProperty('offsetLeft'))
				button.x += config.button.offsetLeft;
			if (config.button.hasOwnProperty('offsetTop'))
				button.y += config.button.offsetTop;

			button.width = config.button.hasOwnProperty('width') ? config.button.width : 30;
			button.height = config.button.hasOwnProperty('height') ? config.button.height : 25;
			button.validateNow();

			return button;
		}
	}
}
