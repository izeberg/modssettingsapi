package poliroid.gui.lobby.modsSettings.components
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import scaleform.clik.constants.InvalidationType;
	import scaleform.clik.core.UIComponent;
	import net.wg.gui.components.advanced.FieldSet;
	import poliroid.gui.lobby.modsSettings.controls.StateSwitcher;
	import poliroid.gui.lobby.modsSettings.events.InteractiveEvent;
	import poliroid.gui.lobby.modsSettings.utils.ComponentsFactory;
	import poliroid.gui.lobby.modsSettings.utils.Constants;

	public class ModsSettingsComponent extends UIComponent
	{
		public var modLinkage:String;
		public var modEnabled:Boolean = true;
		public var data:Object;
		public var components:Array;

		private var _stateSwitcher:StateSwitcher;

		public function ModsSettingsComponent(linkage:String)
		{
			super();

			modLinkage = linkage;
			components = new Array();
		}

		public function setData(newData:Object):void
		{
			if (newData != null)
			{
				data = newData;
				invalidate(InvalidationType.DATA);
			}
		}

		public function getConfigData():Object
		{
			var result:Object = new Object();

			for (var i:Number = 0; i < components.length; i++)
			{
				var component:Object = components[i];

				if ('varName' in component.data)
					result[component.data.varName] = component.componentObject[Constants.COMPONENT_RETURN_VALUE_KEY].value;
			}

			if (data.hasOwnProperty('enabled'))
				result['enabled'] = modEnabled;

			return result;
		}

		override protected function configUI():void
		{
			super.configUI();
		}

		override protected function draw():void
		{
			if (isInvalid(InvalidationType.DATA))
				setup();
		}

		private function setup():void
		{
			if (!data)
				return;

			var column1:Array = data.column1;
			var column2:Array = data.column2;
			var paddingTop:Number = Constants.MOD_PADDING_TOP;
			var lastPos:Number = 0;

			if (column1)
				lastPos = createComponents(this, column1, Constants.MOD_PADDING_LEFT, paddingTop);

			if (column2)
			{
				var lastPosTemp:Number = createComponents(this, column2, Constants.MOD_COMPONENT_WIDTH / 2, paddingTop);

				if (lastPosTemp > lastPos)
					lastPos = lastPosTemp;
			}

			if (data.hasOwnProperty('enabled'))
			{
				modEnabled = data.enabled;
				createStateSwitcher();
			}

			var fieldSet:FieldSet = FieldSet(App.utils.classFactory.getObject('FieldSet'));

			fieldSet.textField.htmlText = data.modDisplayName;
			fieldSet.textField.autoSize = TextFieldAutoSize.LEFT;
			fieldSet.width = Constants.MOD_COMPONENT_WIDTH;
			fieldSet.height = lastPos + Constants.MOD_PADDING_BOTTOM;
			fieldSet.textField.y = fieldSet.textField.y - 2;

			var textFormat:TextFormat = fieldSet.textField.getTextFormat();

			textFormat.bold = true;
			textFormat.size = 15;
			fieldSet.textField.setTextFormat(textFormat);

			addChildAt(fieldSet, 0);
			height = fieldSet.height;
			updateComponentsState();
		}

		private function handleComponentEvent(event:InteractiveEvent = null):void
		{
			dispatchEvent(new InteractiveEvent(InteractiveEvent.SETTINGS_CHANGED, modLinkage));
		}

		private function createComponents(parentObj:UIComponent, column:Array, x:Number, y:Number):Number
		{
			var lastPos:Number = y;

			for (var i:Number = 0; i < column.length; i++)
			{
				var component:DisplayObject = getComponentByType(column[i]);

				component.addEventListener(InteractiveEvent.VALUE_CHANGED, handleComponentEvent);
				components.push({'componentObject': component, 'data': column[i]});
				component.x = x;
				component.y = lastPos + Constants.COMPONENT_MARGIN_BOTTOM;
				lastPos = component.y + component.height;
				parentObj.addChild(component);
			}

			return lastPos;
		}

		private function createStateSwitcher():void
		{
			_stateSwitcher = App.utils.classFactory.getComponent('StateSwitcherUI', StateSwitcher);
			_stateSwitcher.selected = modEnabled;
			_stateSwitcher.x = Constants.MOD_COMPONENT_WIDTH - 41;
			_stateSwitcher.y = 16;
			addChild(_stateSwitcher);
			_stateSwitcher.addEventListener(MouseEvent.CLICK, handleStateSwitcherClick);
		}

		private function handleStateSwitcherClick(event:MouseEvent):void
		{
			App.utils.focusHandler.setFocus(this);
			var button:StateSwitcher = StateSwitcher(event.target);

			modEnabled = button.selected;
			handleComponentEvent();
			updateComponentsState();
		}

		private function updateComponentsState():void
		{
			for (var i:Number = 0; i < components.length; i++)
			{
				var component:MovieClip = MovieClip(components[i].componentObject);

				component.alpha = modEnabled ? 1 : 0.5;
				component.mouseEnabled = modEnabled;
				component.mouseChildren = modEnabled;
				component.tabChildren = modEnabled;
			}
		}

		private function getComponentByType(componentObj:Object):DisplayObject
		{
			switch (componentObj.type)
			{
				case 'Label':
					return ComponentsFactory.createLabel(componentObj.text, componentObj.tooltip);
				case 'Empty':
					return ComponentsFactory.createEmpty(400, Constants.EMPTY_COMPONENT_HEIGHT);
				case 'CheckBox':
					return ComponentsFactory.createCheckBox(componentObj, modLinkage, componentObj.text, componentObj.value, componentObj.tooltip);
				case 'RadioButtonGroup':
					return ComponentsFactory.createRadioButtonGroup(componentObj, modLinkage, componentObj.varName, componentObj.options, componentObj.text, componentObj.tooltip, componentObj.value);
				case 'Slider':
					return ComponentsFactory.createSlider(componentObj, modLinkage, componentObj.minimum, componentObj.maximum, componentObj.snapInterval, componentObj.value, componentObj.format, componentObj.text, componentObj.tooltip);
				case 'Dropdown':
					return ComponentsFactory.createDropdown(componentObj, modLinkage, componentObj.options, componentObj.text, componentObj.tooltip, componentObj.value);
				case 'TextInput':
					return ComponentsFactory.createTextInput(componentObj, componentObj.text, componentObj.tooltip, componentObj.value);
				case 'HotKey':
					return ComponentsFactory.createHotKey(componentObj, modLinkage, componentObj.value, componentObj.text, componentObj.tooltip);
				case 'NumericStepper':
					return ComponentsFactory.createNumericStepper(componentObj, modLinkage, componentObj.minimum, componentObj.maximum, componentObj.snapInterval, componentObj.value, componentObj.text, componentObj.tooltip);
				case 'ColorChoice':
					return ComponentsFactory.createColorChoice(componentObj, modLinkage, componentObj.value, componentObj.text, componentObj.tooltip);
				case 'RangeSlider':
					return ComponentsFactory.createRangeSlider(componentObj, modLinkage);
				default:
					DebugUtils.LOG_ERROR('[ModsSettings API] Unexpected type of component: ', componentObj.type);
					return new MovieClip();
			}
		}
	}
}
