package poliroid.gui.lobby.modsSettingsApi
{
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	import scaleform.clik.events.InputEvent;
	import net.wg.infrastructure.base.AbstractView;
	
	import poliroid.gui.lobby.modsSettingsApi.components.ModApiComponent;
	import poliroid.gui.lobby.modsSettingsApi.components.ModApiWindowBackground;
	import poliroid.gui.lobby.modsSettingsApi.components.ModApiWindowContent;
	import poliroid.gui.lobby.modsSettingsApi.components.ModApiWindowFooter;
	import poliroid.gui.lobby.modsSettingsApi.components.ModApiWindowHeader;
	import poliroid.gui.lobby.modsSettingsApi.data.HotKeyControlVO;
	import poliroid.gui.lobby.modsSettingsApi.data.ModsSettingsStaticVO;
	import poliroid.gui.lobby.modsSettingsApi.events.InteractiveEvent;
	import poliroid.gui.lobby.modsSettingsApi.lang.STRINGS;
	import poliroid.gui.lobby.modsSettingsApi.utils.Constants;

	public class ModsSettingsWindow extends AbstractView
	{
		public var requestModsData:Function = null;
		public var sendModsData:Function = null;
		public var buttonAction:Function = null;
		public var hotKeyAction:Function = null;
		public var closeView:Function = null;
		
		private var modsArray:Array = null;
		private var modsData:Object = null;
		private var configChanged:Boolean = false;
		private var configChangedLinkages:Array = null;
		
		public var header:ModApiWindowHeader = null;
		public var content:ModApiWindowContent = null;
		public var footer:ModApiWindowFooter = null;
		public var background:ModApiWindowBackground = null;

		public function ModsSettingsWindow() : void
		{
			super();
			configChanged = false;
			configChangedLinkages = new Array();
			modsArray = new Array();
		}
		
		override protected function onPopulate() : void
		{
			super.onPopulate();
			
			App.gameInputMgr.setKeyHandler(Keyboard.ESCAPE, KeyboardEvent.KEY_DOWN, onEscapeKeyDownHandler, true);
			
			footer.addEventListener(InteractiveEvent.BUTTON_OK_CLICK, handleButtonOK);
			footer.addEventListener(InteractiveEvent.BUTTON_CANCEL_CLICK, handleButtonCancel);
			footer.addEventListener(InteractiveEvent.BUTTON_APPLY_CLICK, handleButtonApply);

			header.addEventListener(InteractiveEvent.BUTTON_CLOSE_CLICK, handleButtonClose);
			
			content.container.addEventListener(InteractiveEvent.SETTINGS_CHANGED, handleModSettingsChanged);
			content.container.addEventListener(InteractiveEvent.BUTTON_CLICK, handleModSettingsButtonClick);
			content.container.addEventListener(InteractiveEvent.HOTKEY_ACTION, handleModSettingsHotkeyAction);
			
			App.stage.addEventListener(Event.RESIZE, updatePositions);
			
			updatePositions();
			requestModsData();
		}
		
		override protected function onDispose() : void
		{
			
			App.gameInputMgr.clearKeyHandler(Keyboard.ESCAPE, KeyboardEvent.KEY_DOWN, onEscapeKeyDownHandler);
			
			footer.removeEventListener(InteractiveEvent.BUTTON_OK_CLICK, handleButtonOK);
			footer.removeEventListener(InteractiveEvent.BUTTON_CANCEL_CLICK, handleButtonCancel);
			footer.removeEventListener(InteractiveEvent.BUTTON_APPLY_CLICK, handleButtonApply);
			
			header.removeEventListener(InteractiveEvent.BUTTON_CLOSE_CLICK, handleButtonClose);
			
			App.stage.removeEventListener(Event.RESIZE, updatePositions);

			App.toolTipMgr.hide();
			
			footer = null;
			header = null;
			content = null;
			background = null;
			
			super.onDispose();
		}
		
		private function updatePositions(e:Event = null) : void
		{
			var appWidth:Number = App.appWidth;
			var appHeight:Number = App.appHeight;
			background.updateStage(appWidth, appHeight);
			header.updateStage(appWidth, appHeight);
			content.updateStage(appWidth, appHeight);
			footer.updateStage(appWidth, appHeight);
		}

		public function as_setStaticData(data:Object) : void
		{
			var model:ModsSettingsStaticVO = new ModsSettingsStaticVO(data);
			header.updateStaticData(model);
			footer.updateStaticData(model);
			STRINGS.updateStaticData(model);
		}
		
		public function as_setData(data:Object):void
		{
			modsData = data;
			var lastPos:int = 0;
			for (var linkage:String in modsData)
			{
				var mod:ModApiComponent = new ModApiComponent(linkage);
				mod.setData(modsData[linkage]);
				mod.validateNow();
				
				mod.y = lastPos;
				lastPos = mod.y + mod.height + Constants.MOD_MARGIN_BOTTOM;
				
				content.container.addChild(mod);
				modsArray.push(mod);
			}
		}
		
		public function as_updateHotKeys(data:Object) : void 
		{
			for each (var mod:ModApiComponent in modsArray)
			{
				if (data.hasOwnProperty(mod.modLinkage))
				{
					for each (var component:Object in mod.components)
					{
						if (component.data.hasOwnProperty('varName') && component.data.varName in data[mod.modLinkage])
						{
							var hotKeyData:Object = data[mod.modLinkage][component.data.varName]
							var hotKeyControlVO:Object = new HotKeyControlVO(hotKeyData);
							component.componentObject['control'].updateData(hotKeyControlVO);
						}
					}
				}
			}
		}
		
		private function collectModsData():Object
		{
			var result:Object = new Object();
			
			for each (var mod:ModApiComponent in modsArray)
			{
				if (configChangedLinkages.indexOf(mod.modLinkage) != -1)
				{
					result[mod.modLinkage] = mod.getConfigData();
				}
			}
			return result;
		}
		
		private function handleModSettingsChanged(event:InteractiveEvent):void
		{
			configChanged = true;
			footer.buttonApply.enabled = true;
			if (configChangedLinkages.indexOf(event.linkage) == -1)
			{
				configChangedLinkages.push(event.linkage);
			}
		}
		
		private function handleModSettingsButtonClick(event:InteractiveEvent):void
		{
			buttonAction(event.linkage, event.varName, event.value);
		}
		
		private function handleModSettingsHotkeyAction(event:InteractiveEvent):void
		{
			hotKeyAction(event.linkage, event.varName, event.value);
		}
		
		private function handleButtonOK(event:InteractiveEvent) : void
		{
			if (configChanged)
			{
				var config:Object = collectModsData();
				sendModsData(App.utils.JSON.encode(config));
			}
			closeView();
		}
		
		private function handleButtonApply(event:InteractiveEvent) : void
		{
			var config:Object = collectModsData();
			sendModsData(App.utils.JSON.encode(config));
			configChanged = false;
			footer.buttonApply.enabled = false;
		}

		private function handleButtonCancel(event:InteractiveEvent) : void
		{
			closeView();
		}
		
		private function handleButtonClose(event:InteractiveEvent) : void
		{
			closeView();
		}
		
		private function onEscapeKeyDownHandler(event:InputEvent) : void
		{
			closeView();
		}
	}
}