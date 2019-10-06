package poliroid.gui.lobby.modsSettingsApi.utils
{
	import net.wg.gui.components.controls.NumericStepper;
	import net.wg.gui.components.controls.SoundButtonEx;
	import net.wg.gui.components.controls.TextInput;
	import net.wg.gui.components.controls.CheckBox;
	import net.wg.gui.components.controls.DropdownMenu;
	import net.wg.gui.components.controls.ButtonIconNormal;
	import net.wg.gui.components.controls.LabelControl;
	import net.wg.gui.components.controls.SoundButton;
	import net.wg.gui.components.controls.InfoIcon;
	import net.wg.gui.components.controls.Slider;
	import net.wg.gui.components.controls.RadioButton;
	import net.wg.gui.components.controls.RangeSlider;
	import net.wg.gui.components.advanced.FieldSet;
	
	import scaleform.clik.controls.ButtonGroup;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.SliderEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.IndexEvent;
	import scaleform.clik.data.DataProvider;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	
	import poliroid.gui.lobby.modsSettingsApi.controls.HotKeyControl;
	import poliroid.gui.lobby.modsSettingsApi.controls.ColorChoiceButton;
	import poliroid.gui.lobby.modsSettingsApi.events.InteractiveEvent;
	
	public class ComponentsHelper
	{
		
		public function ComponentsHelper()
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
			mc.height = height;
			return mc;
		}
		
		public static function createLabel(text:String, tooltipText:String = ""):DisplayObject
		{
			var labelUI:UIComponent = new UIComponent();
			var lb:LabelControl = LabelControl(App.utils.classFactory.getComponent("LabelControl", LabelControl));
			lb.width = 800;
			lb.text = text;
			if (tooltipText)
			{
				lb.toolTip = tooltipText;
				lb.infoIcoType = InfoIcon.TYPE_INFO;
			}
			labelUI.addChild(lb);
			lb.validateNow();
			
			var result:MovieClip = new MovieClip();
			result.addChild(labelUI);
			result["label"] = lb;
			return result;
		}
		
		public static function createCheckBox(componentCFG:Object, modLinkage:String, label:String, selected:Boolean, tooltipText:String = ""):DisplayObject
		{
			var checkboxUI:UIComponent = new UIComponent();
			var cb:CheckBox = CheckBox(App.utils.classFactory.getComponent("CheckBox", CheckBox));
			cb.label = label;
			cb.selected = true;
			cb.invalidateSize();
			cb.invalidateState();
			cb.invalidateData();
			cb.selected = selected;
			cb.toolTip = tooltipText;
			cb.infoIcoType = tooltipText ? InfoIcon.TYPE_INFO : "";
			cb.width = 800;
			checkboxUI.addChild(cb);
			cb.addEventListener(Event.SELECT, handleComponentEvent);
			
			if (componentCFG.hasOwnProperty("button"))
			{
				var positionY:Number = cb.y + Constants.MOD_MARGIN_BOTTOM - 3;
				var positionX:Number = cb.x + cb.textField.textWidth + Constants.BUTTON_MARGIN_LEFT + 20;
				if (tooltipText) positionX += 25;
				
				var button:DisplayObject = createDynamicButton(componentCFG, positionX, positionY);
				
				button.addEventListener(ButtonEvent.CLICK, function() : void {
					button.dispatchEvent(new InteractiveEvent(InteractiveEvent.BUTTON_CLICK, modLinkage, componentCFG.varName, cb.selected));
				});
				checkboxUI.addChild(button);
			}
			
			var result:MovieClip = new MovieClip();
			result.addChild(checkboxUI);
			result[Constants.COMPONENT_RETURN_VALUE_KEY] = new ValueProxy(cb, "selected");
			return result;
		}
		
		public static function createRadioButtonGroup(componentCFG:Object, modLinkage:String, groupName:String, options:Array, headerText:String = "", tooltipText:String = "", selectedIndex:Number = 0):DisplayObject
		{
			var radioButtonsUI:UIComponent = new UIComponent();
			var headerMargin:Number = headerText ? Constants.COMPONENT_HEADER_MARGIN : 0;
			if (headerText)
			{
				var lb:DisplayObject = ComponentsHelper.createLabel(headerText, tooltipText);
				lb.x = lb.y = 0;
				radioButtonsUI.addChild(lb);
			}
			
			var buttonGroup:ButtonGroup = ButtonGroup.getGroup(groupName, radioButtonsUI);
			for (var i:Number = 0; i < options.length; i++)
			{
				var radioButton:RadioButton = RadioButton(App.utils.classFactory.getComponent("RadioButton", RadioButton));
				radioButton.y = i * Constants.RADIO_BUTTONS_MARGIN + headerMargin;
				radioButton.label = options[i].label;
				radioButtonsUI.addChild(radioButton);
				buttonGroup.addButton(radioButton);
				radioButton.addEventListener(MouseEvent.CLICK, handleComponentEvent);
			}
			buttonGroup.setSelectedButtonByIndex(selectedIndex);
			
			if (componentCFG.hasOwnProperty("button"))
			{
				var positionX:Number = 0;
				var positionY:Number = 0;
				var rb:* = buttonGroup.getButtonAt(0);
				if (headerText)
				{
					positionX = lb.x + lb["label"].textField.textWidth + Constants.BUTTON_MARGIN_LEFT;
					if (tooltipText)
					{
						positionX += 25;
					}
				}
				else
				{
					positionX = rb.x + rb.width + Constants.BUTTON_MARGIN_LEFT;
				}
				
				var button:DisplayObject = createDynamicButton(componentCFG, positionX, positionY);
				button.addEventListener(ButtonEvent.CLICK, function():void {
					button.dispatchEvent(new InteractiveEvent(InteractiveEvent.BUTTON_CLICK, modLinkage, componentCFG.varName, buttonGroup.selectedIndex));
				});
				radioButtonsUI.addChild(button);
			}
			
			var result:MovieClip = new MovieClip();
			result.addChild(radioButtonsUI);
			result[Constants.COMPONENT_RETURN_VALUE_KEY] = new ValueProxy(buttonGroup, "selectedIndex");
			return result;
		}
		
		public static function createDropdown(componentCFG:Object, modLinkage:String, options:Array, headerText:String = "", tooltipText:String = "", selectedIndex:Number = 0):DisplayObject
		{
			var dropdownUI:UIComponent = new UIComponent();
			var headerMargin:Number = headerText ? Constants.COMPONENT_HEADER_MARGIN : 0;
			if (headerText)
			{
				var lb:DisplayObject = ComponentsHelper.createLabel(headerText, tooltipText);
				lb.x = lb.y = 0;
				dropdownUI.addChild(lb);
			}
			
			var dropdown:DropdownMenu = DropdownMenu(App.utils.classFactory.getObject("DropdownMenuUI"));
			dropdown.y = headerMargin;
			dropdown.width = componentCFG.hasOwnProperty("width") ? componentCFG.width: 200;
			
			dropdown.rowCount = options.length;
			dropdown.scrollBar = "";
			
			dropdown.itemRenderer = App.utils.classFactory.getClass("DropDownListItemRendererSound");
			dropdown.dropdown = "DropdownMenu_ScrollingList";
			dropdown.dataProvider = new DataProvider(options);
			dropdown.selectedIndex = selectedIndex;
			dropdown.validateNow();
			dropdownUI.addChild(dropdown);
			dropdown.handleScroll = false;
			dropdown.addEventListener(ListEvent.INDEX_CHANGE, handleComponentEvent);
			
			dropdown["componentInspectorSetting"] = true;
			dropdown.inspectableMenuOffset = { "top":-5, "right":-6, "bottom":0, "left":3 };
			dropdown["componentInspectorSetting"] = false;
			
			if (componentCFG.hasOwnProperty("button"))
			{
				var positionY:Number = dropdown.y + Constants.MOD_MARGIN_BOTTOM - 3;
				var positionX:Number = dropdown.x + dropdown.width + Constants.BUTTON_MARGIN_LEFT;
				
				var button:DisplayObject = createDynamicButton(componentCFG, positionX, positionY);
				button.addEventListener(ButtonEvent.CLICK, function():void {
					button.dispatchEvent(new InteractiveEvent(InteractiveEvent.BUTTON_CLICK, modLinkage, componentCFG.varName, dropdown.selectedIndex));
				});
				dropdownUI.addChild(button);
			}
			
			var result:MovieClip = new MovieClip();
			result.addChild(dropdownUI);
			result[Constants.COMPONENT_RETURN_VALUE_KEY] = new ValueProxy(dropdown, "selectedIndex");
			return result;
		}
		
		public static function createSlider(componentCFG:Object, modLinkage:String, min:Number, max:Number, interval:Number, value:Number, format:String, headerText:String = "", tooltipText:String = ""):DisplayObject
		{
			var sliderUI:UIComponent = new UIComponent();
			var headerMargin:Number = headerText ? Constants.COMPONENT_HEADER_MARGIN : 0;
			if (headerText)
			{
				var lb:DisplayObject = ComponentsHelper.createLabel(headerText, tooltipText);
				lb.x = lb.y = 0;
				sliderUI.addChild(lb);
			}
			
			var slider:Slider = Slider(App.utils.classFactory.getComponent("Slider", Slider));
			slider.y = headerMargin;
			slider.width = componentCFG.hasOwnProperty("width") ? componentCFG.width: 200;
			slider.minimum = min;
			slider.maximum = max;
			slider.snapInterval = interval;
			slider.snapping = true;
			slider.liveDragging = true;
			slider.value = value;
			sliderUI.addChild(slider);
			
			slider.addEventListener(SliderEvent.VALUE_CHANGE, handleComponentEvent);
			
			function getFormattedString(format:String, value:Number):String
			{
				value = Math.round(value * 100) / 100
				return format.split(Constants.SLIDER_VALUE_KEY).join(value.toString());
			}
			
			if (format)
			{
				var formattedString:String = getFormattedString(format, slider.value);
				var valueLabel:DisplayObject = ComponentsHelper.createLabel(formattedString, "");
				valueLabel.y = slider.y + 2;
				valueLabel.x = slider.x + slider.width + Constants.SLIDER_VALUE_MARGIN;
				sliderUI.addChild(valueLabel);
				slider.addEventListener(SliderEvent.VALUE_CHANGE, function(event:SliderEvent):* {
					valueLabel["label"].text = getFormattedString(format, event.value);
				});
			}
			
			if (componentCFG.hasOwnProperty("button"))
			{
				var positionY:Number = headerMargin;
				var positionX:Number = slider.x + slider.width + Constants.SLIDER_VALUE_MARGIN + 15;
				if (format) positionX += 15;
				
				var button:DisplayObject = createDynamicButton(componentCFG, positionX, positionY);
				button.addEventListener(ButtonEvent.CLICK, function():void {
					button.dispatchEvent(new InteractiveEvent(InteractiveEvent.BUTTON_CLICK, modLinkage, componentCFG.varName, slider.value));
				});
				sliderUI.addChild(button);
			}
			
			var result:MovieClip = new MovieClip();
			result.addChild(sliderUI);
			result[Constants.COMPONENT_RETURN_VALUE_KEY] = new ValueProxy(slider, "value");
			
			slider.addEventListener(MouseEvent.MOUSE_WHEEL, function (e:MouseEvent):* { 
				e.stopImmediatePropagation(); 
				result.parent.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_WHEEL, e.bubbles, e.cancelable, e.localX, e.localY, e.relatedObject, e.ctrlKey, e.altKey, e.shiftKey, e.buttonDown, e.delta));
			});
			
			return result;
		}
		
		public static function createTextInput(componentCFG:Object, headerText:String = "", tooltipText:String = "", value:String = ""):DisplayObject
		{
			var textInputUI:UIComponent = new UIComponent();
			
			
			var headerMargin:Number = headerText ? Constants.COMPONENT_HEADER_MARGIN : 0;
			if (headerText)
			{
				var lb:DisplayObject = ComponentsHelper.createLabel(headerText, tooltipText);
				lb.x = lb.y = 0;
				textInputUI.addChild(lb);
			}
			
			
			var textinput:TextInput = TextInput(App.utils.classFactory.getComponent("TextInput", TextInput));
			textinput.y = headerMargin;
			textinput.width = componentCFG.hasOwnProperty("width") ? componentCFG.width: 200;
			textinput.text = value;
			textinput.validateNow();
			textInputUI.addChild(textinput);
			
			textinput.addEventListener(InputEvent.INPUT, handleComponentEvent);
			
			var result:MovieClip = new MovieClip();
			result.addChild(textInputUI);
			result[Constants.COMPONENT_RETURN_VALUE_KEY] = new ValueProxy(textinput, "text");
			return result;
		}
		
		public static function createNumericStepper(componentCFG:Object, modLinkage:String, minimum:Number, maximum:Number, stepSize:Number, value:Number, text:String, tooltip:String):DisplayObject
		{
			var numericStepperUI:UIComponent = new UIComponent();

			if (text) {
				var lb = ComponentsHelper.createLabel(text, tooltip)
				lb.y = 4
				numericStepperUI.addChild(lb);
			}

			var numericStepper:NumericStepper = NumericStepper(App.utils.classFactory.getComponent("NumericStepper", NumericStepper));
			numericStepper.x = 315;
			if (componentCFG.hasOwnProperty('canManualInput')) {
				numericStepper.canManualInput = componentCFG.canManualInput;
			}
			numericStepper.minimum = minimum;
			numericStepper.maximum = maximum;
			numericStepper.stepSize = stepSize;
			numericStepper.value = value;
			numericStepper.validateNow();
			numericStepper.addEventListener(IndexEvent.INDEX_CHANGE, handleComponentEvent);

			numericStepperUI.addChild(numericStepper);
			
			var result:MovieClip = new MovieClip();
			result.addChild(numericStepperUI);
			result[Constants.COMPONENT_RETURN_VALUE_KEY] = new ValueProxy(numericStepper, "value");
			return result;
		}
		
		public static function createHotKey(componentCFG:Object, modLinkage:String, value:Array, headerText:String = "", tooltipText:String = "") : DisplayObject
		{
			var hotKeyUI:UIComponent = new UIComponent();
			
			var label:DisplayObject = ComponentsHelper.createLabel(headerText, tooltipText);
			label.x = 0;
			label.y = 4;
			hotKeyUI.addChild(label);
			
			var hotkeyctrl:HotKeyControl = App.utils.classFactory.getComponent("HotKeyControlUI", HotKeyControl);
			hotkeyctrl.x = 315;
			hotkeyctrl.y = 0;
			hotKeyUI.addChild(hotkeyctrl);
			
			var result:MovieClip = new MovieClip();
			result.addChild(hotKeyUI);
			result[Constants.COMPONENT_RETURN_VALUE_KEY] = new ValueProxy(hotkeyctrl, "keySet");
			result["control"] = hotkeyctrl;
			return result;
		}
		
		public static function createColorChoice(componentCFG:Object, modLinkage:String, value:String, headerText:String = "", tooltipText:String = "") : DisplayObject
		{
			var colorChoiceUI:UIComponent = new UIComponent();
			
			var label:DisplayObject = ComponentsHelper.createLabel(headerText, tooltipText);
			label.x = 0;
			label.y = 4;
			colorChoiceUI.addChild(label);
			
			var controller:ColorChoiceButton = App.utils.classFactory.getComponent("ColorChoiceButtonUI", ColorChoiceButton);
			controller.x = 315;
			controller.y = 0;
			controller.color = value;
			colorChoiceUI.addChild(controller);
			controller.addEventListener(InputEvent.INPUT, handleComponentEvent);
			
			var result:MovieClip = new MovieClip();
			result.addChild(colorChoiceUI);
			result[Constants.COMPONENT_RETURN_VALUE_KEY] = new ValueProxy(controller, "color");
			return result;
		}
		
		private static function createDynamicButton(componentCFG:Object, positionX:Number = 0, positionY:Number = 0) : DisplayObject
		{
			var button:*;
			
			if (componentCFG.button.hasOwnProperty("text") && componentCFG.button.text != "")
			{
				button = SoundButtonEx(App.utils.classFactory.getComponent("ButtonNormal", SoundButtonEx));
				button.label = componentCFG.button.text;
			} 
			
			if (componentCFG.button.hasOwnProperty("iconSource") && componentCFG.button.iconSource != "")
			{
				button = ButtonIconNormal(App.utils.classFactory.getComponent("ButtonIconNormalUI", ButtonIconNormal));
				button.iconSource  = componentCFG.button.hasOwnProperty("iconSource") ?  componentCFG.button.iconSource : "";
				button.iconOffsetTop = componentCFG.button.hasOwnProperty("iconOffsetTop") ? componentCFG.button.iconOffsetTop: 0;
				button.iconOffsetLeft = componentCFG.button.hasOwnProperty("iconOffsetLeft") ? componentCFG.button.iconOffsetLeft: 0;
			}
			
			button.x = positionX;
			button.y = positionY;
			
			if (componentCFG.button.hasOwnProperty("offsetLeft")) button.x = button.x + componentCFG.button.offsetLeft;
			if (componentCFG.button.hasOwnProperty("offsetTop")) button.y = button.y + componentCFG.button.offsetTop;
			
			button.width = componentCFG.button.hasOwnProperty("width") ? componentCFG.button.width: 30;
			button.height = componentCFG.button.hasOwnProperty("height") ? componentCFG.button.height: 25;
			
			button.validateNow();

			return button;
		}

		public static function createRangeSlider(componentCFG:Object, modLinkage:String) : DisplayObject
		{			
			var rangeSliderUI:UIComponent = new UIComponent();
			rangeSliderUI.y = rangeSliderUI.y + 7;

			var lb:DisplayObject = ComponentsHelper.createLabel(componentCFG.text,"");
			lb.y = -7;
			lb.x = 0;
			rangeSliderUI.addChild(lb);

			var rangeSlider:RangeSlider = RangeSlider(App.utils.classFactory.getComponent("RangeSliderUI", RangeSlider));
			rangeSlider.y = rangeSlider.y + 33;
			rangeSlider.x = rangeSlider.x + 5;
			rangeSlider.width = 240;

			rangeSlider.maximum = componentCFG.maximum;
			rangeSlider.minimum = componentCFG.minimum;
			rangeSlider.divisionLabelPostfix = componentCFG.divisionLabelPostfix;
			rangeSlider.divisionLabelStep = componentCFG.divisionLabelStep;
			rangeSlider.divisionStep = componentCFG.divisionStep;
			rangeSlider.minRangeDistance = componentCFG.minRangeDistance;
			rangeSlider.snapInterval = componentCFG.snapInterval;
			rangeSlider.leftValue = componentCFG.value[0];
			rangeSlider.rightValue = componentCFG.value[1];

			rangeSlider.focusable = true;
			rangeSlider.snapping = true;
			rangeSlider.rangeMode = true;

			rangeSlider["valueProxyValue"] = [rangeSlider.leftValue, rangeSlider.rightValue];

			var valueLabel:DisplayObject = ComponentsHelper.createLabel("","");
			valueLabel.y = rangeSlider.y + 2;
			valueLabel.x = rangeSlider.x + rangeSlider.width + Constants.SLIDER_VALUE_MARGIN + 5;
			valueLabel["label"].text = rangeSlider.leftValue + " / " + rangeSlider.rightValue;
			rangeSliderUI.addChild(valueLabel);

			rangeSlider.addEventListener(SliderEvent.VALUE_CHANGE, function(event:*):*
			{
				valueLabel["label"].text = rangeSlider.leftValue + " / " + rangeSlider.rightValue;
				rangeSlider["valueProxyValue"] = [rangeSlider.leftValue, rangeSlider.rightValue];
				handleComponentEvent(event);
			});
			rangeSlider.validateNow();
			rangeSliderUI.addChild(rangeSlider);

			var result:MovieClip = new MovieClip();
			result.addChild(rangeSliderUI);
			result[Constants.COMPONENT_RETURN_VALUE_KEY] = new ValueProxy(rangeSlider, "valueProxyValue");

			return result;
		}
	}

}
