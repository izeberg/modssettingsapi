package poliroid.components.lobby
{
	import poliroid.events.ComponentEvent;
	import poliroid.utils.ComponentsHelper;
	import poliroid.utils.Constants;
	import poliroid.utils.Logger;
	import poliroid.events.*;
	import poliroid.events.ModsSettingsApiComponentEvent;
	import poliroid.utils.*;
	import poliroid.components.lobby.ButtonModEnable;
	import flash.display.*;
	import flash.events.*;
	import flash.text.TextFormat;
	import scaleform.clik.constants.*;
	import scaleform.clik.core.*;
	
	import net.wg.gui.components.advanced.FieldSet;
	
	public class ModsSettingsApiComponent extends UIComponent
	{
		
		public var modLinkage:String;
		public var modEnabled:Boolean = true;
		public var data:Object;
		public var components:Array;
		private var modEnabledButton:ButtonModEnable;
		
		public function ModsSettingsApiComponent(linkage:String)
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
			Logger.DebugLog("getConfigData:: Getting config data for mod: " + this.modLinkage);
			var result:Object = new Object();
			try
			{
				for (var i:Number = 0; i < this.components.length; i++)
				{
					var component:Object = this.components[i];
					if ("varName" in component.data)
					{
						var componentValue:* = component.componentObject[Constants.COMPONENT_RETURN_VALUE_KEY].value;
						Logger.DebugLog("getConfigData:: Config value from component " + component.data.varName + ": " + componentValue);
						result[component.data.varName] = component.componentObject[Constants.COMPONENT_RETURN_VALUE_KEY].value;
					}
				}
				if (this.data.hasOwnProperty("enabled")) {
					result["enabled"] = this.modEnabled;
				}
				return result;
			}
			catch (err:Error)
			{
				Logger.ErrorLog(this.modLinkage + "getConfigData()", err.message);
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
			try
			{
				if (this.data)
				{
					
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
						this.modEnabledButton = new ButtonModEnable();
						this.modEnabledButton.isEnabled = this.modEnabled;
						this.modEnabledButton.y = 16;
						this.modEnabledButton.x = 800;
						this.addChild(this.modEnabledButton);
						this.modEnabledButton.addEventListener(MouseEvent.CLICK, this.handleButtonEnableClick);
					}
					
					var fieldSet:FieldSet = FieldSet(App.utils.classFactory.getObject("FieldSet"));
					fieldSet.label = this.data.modDisplayName;
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
			}
			catch (err:Error)
			{
				Logger.ErrorLog(this.modLinkage + ".setup()", err.message);
			}
		}
		
		private function handleComponentEvent(event:ComponentEvent):void
		{
			this.dispatchEvent(new ModsSettingsApiComponentEvent(ModsSettingsApiComponentEvent.MOD_SETTINGS_CHANGED, this.modLinkage, true));
		}
		
		private function createComponents(parentObj:UIComponent, column:Array, x:Number, y:Number):Number
		{
			var lastPos:Number = y;
			for (var i:Number = 0; i < column.length; i++)
			{
				var component:DisplayObject = this.getComponentByType(column[i]);
				component.addEventListener(ComponentEvent.VALUE_CHANGED, this.handleComponentEvent);
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
			var btn:ButtonModEnable = ButtonModEnable(event.target);
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
				default: 
					return new MovieClip();
			}
		}
		
	}

}
