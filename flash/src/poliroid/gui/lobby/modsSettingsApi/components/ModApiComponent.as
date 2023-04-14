package poliroid.gui.lobby.modsSettingsApi.components
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import scaleform.clik.constants.InvalidationType;
	import scaleform.clik.core.UIComponent;
	
	import net.wg.gui.components.advanced.FieldSet;
	
	import poliroid.gui.lobby.modsSettingsApi.controls.StatusSwitcher;
	import poliroid.gui.lobby.modsSettingsApi.events.InteractiveEvent;
	import poliroid.gui.lobby.modsSettingsApi.utils.ComponentsHelper;
	import poliroid.gui.lobby.modsSettingsApi.utils.Constants;
	
	public class ModApiComponent extends UIComponent
	{
		
		public var modLinkage:String;
		public var modEnabled:Boolean = true;
		public var data:Object;
		public var components:Array;
		private var modEnabledButton:StatusSwitcher;
		
		public function ModApiComponent(linkage:String)
		{
			super();
			this.modLinkage = linkage;
			this.components = new Array();
		}
		
		public function setData(newData:Object):void
		{
			if (newData != null)
			{
				this.data = newData;
				invalidate(InvalidationType.DATA);
			}
		}
		
		public function getConfigData():Object
		{
			var result:Object = new Object();
		
			for (var i:Number = 0; i < this.components.length; i++)
			{
				var component:Object = this.components[i];
				if ("varName" in component.data)
				{
					var componentValue:* = component.componentObject[Constants.COMPONENT_RETURN_VALUE_KEY].value;
					result[component.data.varName] = component.componentObject[Constants.COMPONENT_RETURN_VALUE_KEY].value;
				}
			}
			if (this.data.hasOwnProperty("enabled"))
			{
				result["enabled"] = this.modEnabled;
			}
			return result;
		}
		
		override protected function configUI():void
		{
			super.configUI();
		}
		
		override protected function draw():void
		{
			if (isInvalid(InvalidationType.DATA))
			{
				this.setup();
			}
		}
		
		private function setup():void
		{
			if (!this.data)
			{
				return;
			}
			
			var column1:Array = this.data.column1;
			var column2:Array = this.data.column2;
			var paddingTop:Number = Constants.MOD_PADDING_TOP;
			var lastPos:Number = 0;
			if (column1)
			{
				lastPos = this.createComponents(this, column1, Constants.MOD_PADDING_LEFT, paddingTop);
			}
			if (column2)
			{
				var lastPosTemp:Number = this.createComponents(this, column2, Constants.MOD_COMPONENT_WIDTH / 2, paddingTop);
				if (lastPosTemp > lastPos)
					lastPos = lastPosTemp;
			}
			
			if (this.data.hasOwnProperty("enabled")) {
				this.modEnabled = this.data.enabled;
				this.modEnabledButton = App.utils.classFactory.getComponent('StatusSwitcherUI', StatusSwitcher);
				this.modEnabledButton.isEnabled = this.modEnabled;
				this.modEnabledButton.y = 16;
				this.modEnabledButton.x = Constants.MOD_COMPONENT_WIDTH - 41;
				this.addChild(this.modEnabledButton);
				this.modEnabledButton.addEventListener(MouseEvent.CLICK, this.handleButtonEnableClick);
			}
			
			var fieldSet:FieldSet = FieldSet(App.utils.classFactory.getObject("FieldSet"));
			fieldSet.textField.htmlText = this.data.modDisplayName;
			fieldSet.textField.autoSize = TextFieldAutoSize.LEFT;
			fieldSet.width = Constants.MOD_COMPONENT_WIDTH;
			fieldSet.height = lastPos + Constants.MOD_PADDING_BOTTOM;
			
			fieldSet.textField.y = fieldSet.textField.y - 2;
			var tf:TextFormat = fieldSet.textField.getTextFormat();
			tf.bold = true;
			tf.size = 15;
			fieldSet.textField.setTextFormat(tf);
			
			this.addChildAt(fieldSet, 0);
			this.height = fieldSet.height;
			
			this.updateComponentsState();
		}
		
		private function handleComponentEvent(event:InteractiveEvent):void
		{
			dispatchEvent(new InteractiveEvent(InteractiveEvent.SETTINGS_CHANGED, this.modLinkage));
		}
		
		private function createComponents(parentObj:UIComponent, column:Array, x:Number, y:Number):Number
		{
			var lastPos:Number = y;
			for (var i:Number = 0; i < column.length; i++)
			{
				var component:DisplayObject = this.getComponentByType(column[i]);
				component.addEventListener(InteractiveEvent.VALUE_CHANGED, this.handleComponentEvent);
				this.components.push({"componentObject": component, "data": column[i]});
				component.x = x;
				component.y = lastPos + Constants.COMPONENT_MARGIN_BOTTOM;
				lastPos = component.y + component.height;
				parentObj.addChild(component);
			}
			return lastPos;
		}
		
		private function handleButtonEnableClick(event:MouseEvent):void
		{
			App.utils.focusHandler.setFocus(this);
			var btn:StatusSwitcher = StatusSwitcher(event.target);
			btn.isEnabled = !btn.isEnabled;
			this.modEnabled = btn.isEnabled;
			this.handleComponentEvent(null);
			this.updateComponentsState();
		}
		
		private function updateComponentsState():void
		{
			for (var i:Number = 0; i < this.components.length; i++)
			{
				var component:MovieClip = MovieClip(this.components[i].componentObject);
				component.alpha = this.modEnabled ? 1 : 0.5;
				component.mouseEnabled = this.modEnabled;
				component.mouseChildren = this.modEnabled;
				component.tabChildren = this.modEnabled;
			}
		}
		
		private function getComponentByType(componentObj:Object):DisplayObject
		{
			switch (componentObj.type)
			{
				case "Label": 
					return ComponentsHelper.createLabel(componentObj.text, componentObj.tooltip);
				case "Empty": 
					return ComponentsHelper.createEmpty(400, Constants.EMPTY_COMPONENT_HEIGHT);
				case "CheckBox": 
					return ComponentsHelper.createCheckBox(componentObj, this.modLinkage, componentObj.text, componentObj.value, componentObj.tooltip);
				case "RadioButtonGroup": 
					return ComponentsHelper.createRadioButtonGroup(componentObj, this.modLinkage, componentObj.varName, componentObj.options, componentObj.text, componentObj.tooltip, componentObj.value);
				case "Slider": 
					return ComponentsHelper.createSlider(componentObj, this.modLinkage, componentObj.minimum, componentObj.maximum, componentObj.snapInterval, componentObj.value, componentObj.format, componentObj.text, componentObj.tooltip);
				case "Dropdown": 
					return ComponentsHelper.createDropdown(componentObj, this.modLinkage, componentObj.options, componentObj.text, componentObj.tooltip, componentObj.value);
				case "TextInput": 
					return ComponentsHelper.createTextInput(componentObj, componentObj.text, componentObj.tooltip, componentObj.value);
				case "HotKey": 
					return ComponentsHelper.createHotKey(componentObj, this.modLinkage, componentObj.value, componentObj.text, componentObj.tooltip);
				case "NumericStepper": 
					return ComponentsHelper.createNumericStepper(componentObj, this.modLinkage, componentObj.minimum, componentObj.maximum, componentObj.snapInterval, componentObj.value, componentObj.text, componentObj.tooltip);
				case "ColorChoice":
					return ComponentsHelper.createColorChoice(componentObj, this.modLinkage, componentObj.value, componentObj.text, componentObj.tooltip);
				case "RangeSlider":
					return ComponentsHelper.createRangeSlider(componentObj, this.modLinkage);
				default: 
					DebugUtils.LOG_ERROR('Unexpected type of component:', componentObj.type)
					return new MovieClip();
			}
		}
		
	}

}
