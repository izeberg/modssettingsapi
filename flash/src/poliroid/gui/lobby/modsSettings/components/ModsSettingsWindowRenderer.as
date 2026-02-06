package poliroid.gui.lobby.modsSettings.components
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import scaleform.clik.constants.InvalidationType;
	import scaleform.clik.core.UIComponent;
	import net.wg.gui.components.advanced.FieldSet;
	import poliroid.gui.lobby.modsSettings.controls.StateSwitcher;
	import poliroid.gui.lobby.modsSettings.events.InteractiveEvent;
	import poliroid.gui.lobby.modsSettings.shared.ComponentsFactory;
	import poliroid.gui.lobby.modsSettings.shared.Constants;

	public class ModsSettingsWindowRenderer extends UIComponent
	{
		private var _linkage:String;
		private var _active:Boolean = true;
		private var _template:Object;
		private var _components:Array;

		private var _stateSwitcher:StateSwitcher;

		public function ModsSettingsWindowRenderer(modLinkage:String)
		{
			super();

			_linkage = modLinkage;
			_components = new Array();
		}

		override protected function draw():void
		{
			if (isInvalid(InvalidationType.DATA))
				setup();
		}

		override protected function onDispose():void
		{
			if (_stateSwitcher)
			{
				_stateSwitcher.removeEventListener(Event.SELECT, handleStateSwitcherClick);
				removeChild(_stateSwitcher);
			}

			super.onDispose();
		}

		private function setup():void
		{
			if (!_template)
				return;

			var leftColumn:Array = _template.column1;
			var rightColumn:Array = _template.column2;
			var paddingTop:Number = Constants.MOD_PADDING_TOP;
			var columnHeight:Number = 0;
			var maxColumnHeight:Number = 0;

			if (leftColumn)
			{
				columnHeight = createComponents(this, leftColumn, Constants.MOD_PADDING_LEFT, paddingTop);
				maxColumnHeight = Math.max(columnHeight, maxColumnHeight);
			}

			if (rightColumn)
			{
				columnHeight = createComponents(this, rightColumn, Constants.MOD_COMPONENT_WIDTH / 2, paddingTop);
				maxColumnHeight = Math.max(columnHeight, maxColumnHeight);
			}

			if (_template.hasOwnProperty('enabled'))
			{
				_active = _template.enabled;
				createStateSwitcher();
			}

			var fieldSet:FieldSet = FieldSet(App.utils.classFactory.getObject('FieldSet'));

			fieldSet.textField.htmlText = _template.modDisplayName;
			fieldSet.textField.autoSize = TextFieldAutoSize.LEFT;
			fieldSet.width = Constants.MOD_COMPONENT_WIDTH;
			fieldSet.height = maxColumnHeight + Constants.MOD_PADDING_BOTTOM;
			fieldSet.textField.y = fieldSet.textField.y - 2;

			var textFormat:TextFormat = fieldSet.textField.getTextFormat();

			textFormat.bold = true;
			textFormat.size = 15;
			fieldSet.textField.setTextFormat(textFormat);

			addChildAt(fieldSet, 0);
			height = fieldSet.height;
			updateComponentsState();
		}

		public function setTemplate(template:Object):void
		{
			if (template != null)
			{
				_template = template;
				invalidate(InvalidationType.DATA);
			}
		}

		public function getSettingsSnapshot():Object
		{
			var result:Object = new Object();

			for each (var component:Object in _components)
			{
				var varName:String = component.config.varName;
				if (!varName) continue;
				result[varName] = component.instance[Constants.COMPONENT_RETURN_VALUE_KEY].value;
			}

			if (_template.hasOwnProperty('enabled'))
				result['enabled'] = _active;

			return result;
		}

		public function getComponent(target:String):Object
		{
			if (!target) return null;

			for each (var component:Object in _components)
			{
				var varName:String = component.config.varName;
				if (!varName) continue;
				if (target == varName) return component;
			}

			return null;
		}

		private function createComponents(parent:UIComponent, column:Array, x:Number, y:Number):Number
		{
			var lastPos:Number = y;

			for (var i:Number = 0; i < column.length; i++)
			{
				var component:DisplayObject = createComponent(column[i]);
				if (!component) continue;

				component.x = x;
				component.y = lastPos + Constants.COMPONENT_MARGIN_BOTTOM;
				component.addEventListener(InteractiveEvent.VALUE_CHANGED, handleComponentEvent);
				_components.push({'instance': component, 'config': column[i]});
				lastPos = component.y + component.height;
				parent.addChild(component);
			}

			return lastPos;
		}

		private function createComponent(config:Object):DisplayObject
		{
			switch (config.type)
			{
				case 'Label':
					return ComponentsFactory.createLabel(config.text, config.tooltip, config.tooltipIcon);
				case 'Link':
					return ComponentsFactory.createLink(config, _linkage, config.text, config.url);
				case 'Empty':
					return ComponentsFactory.createEmpty(400, config.height);
				case 'CheckBox':
					return ComponentsFactory.createCheckBox(config, _linkage, config.text, config.value, config.tooltip, config.tooltipIcon);
				case 'RadioButtonGroup':
					return ComponentsFactory.createRadioButtonGroup(config, _linkage, config.varName, config.options, config.text, config.tooltip, config.tooltipIcon, config.value);
				case 'Slider':
					return ComponentsFactory.createSlider(config, _linkage, config.minimum, config.maximum, config.snapInterval, config.value, config.format, config.text, config.tooltip, config.tooltipIcon);
				case 'StepSlider':
					return ComponentsFactory.createStepSlider(config, _linkage, config.options, config.format, config.text, config.tooltip, config.tooltipIcon, config.value);
				case 'Dropdown':
					return ComponentsFactory.createDropdown(config, _linkage, config.options, config.text, config.tooltip, config.tooltipIcon, config.value);
				case 'TextInput':
					return ComponentsFactory.createTextInput(config, config.text, config.tooltip, config.tooltipIcon, config.value);
				case 'HotKey':
					return ComponentsFactory.createHotKey(config, _linkage, config.value, config.text, config.tooltip, config.tooltipIcon);
				case 'NumericStepper':
					return ComponentsFactory.createNumericStepper(config, _linkage, config.minimum, config.maximum, config.snapInterval, config.value, config.text, config.tooltip, config.tooltipIcon);
				case 'ColorChoice':
					return ComponentsFactory.createColorChoice(config, _linkage, config.value, config.text, config.tooltip, config.tooltipIcon);
				case 'RangeSlider':
					return ComponentsFactory.createRangeSlider(config, _linkage);
				default:
					DebugUtils.LOG_ERROR('[ModsSettingsAPI] Unexpected type of component: ', config.type);
					return null;
			}
		}

		private function createStateSwitcher():void
		{
			_stateSwitcher = App.utils.classFactory.getComponent('StateSwitcherUI', StateSwitcher);
			_stateSwitcher.selected = _active;
			_stateSwitcher.x = Constants.MOD_COMPONENT_WIDTH - 41;
			_stateSwitcher.y = 16;
			addChild(_stateSwitcher);
			_stateSwitcher.addEventListener(Event.SELECT, handleStateSwitcherClick);
		}

		private function updateComponentsState():void
		{
			for (var i:Number = 0; i < _components.length; i++)
			{
				var component:MovieClip = MovieClip(_components[i].instance);

				component.alpha = _active ? 1 : 0.5;
				component.mouseEnabled = _active;
				component.mouseChildren = _active;
				component.tabChildren = _active;
			}
		}

		public function get linkage():String
		{
			return _linkage;
		}

		private function handleComponentEvent(event:InteractiveEvent = null):void
		{
			dispatchEvent(new InteractiveEvent(InteractiveEvent.SETTINGS_CHANGED, _linkage));
		}

		private function handleStateSwitcherClick(event:Event):void
		{
			App.utils.focusHandler.setFocus(this);

			var switcher:StateSwitcher = StateSwitcher(event.target);
			_active = switcher.selected;

			handleComponentEvent();
			updateComponentsState();
		}
	}
}
