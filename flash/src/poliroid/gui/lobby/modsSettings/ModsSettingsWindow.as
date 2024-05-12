package poliroid.gui.lobby.modsSettings
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	import scaleform.clik.events.InputEvent;
	import net.wg.infrastructure.base.AbstractView;

	import poliroid.gui.lobby.modsSettings.components.ModsSettingsComponent;
	import poliroid.gui.lobby.modsSettings.components.ModsSettingsWindowBackground;
	import poliroid.gui.lobby.modsSettings.components.ModsSettingsWindowContent;
	import poliroid.gui.lobby.modsSettings.components.ModsSettingsWindowFooter;
	import poliroid.gui.lobby.modsSettings.components.ModsSettingsWindowHeader;
	import poliroid.gui.lobby.modsSettings.data.HotkeyControlVO;
	import poliroid.gui.lobby.modsSettings.data.ModsSettingsStaticVO;
	import poliroid.gui.lobby.modsSettings.events.InteractiveEvent;
	import poliroid.gui.lobby.modsSettings.lang.STRINGS;
	import poliroid.gui.lobby.modsSettings.utils.Constants;

	public class ModsSettingsWindow extends AbstractView
	{
		public var header:ModsSettingsWindowHeader;
		public var content:ModsSettingsWindowContent;
		public var footer:ModsSettingsWindowFooter;
		public var background:ModsSettingsWindowBackground;

		public var requestModsData:Function;
		public var sendModsData:Function;
		public var buttonAction:Function;
		public var hotKeyAction:Function;
		public var closeView:Function;

		private var modsArray:Array;
		private var modsData:Object;
		private var configChanged:Boolean = false;
		private var configChangedLinkages:Array;

		public function ModsSettingsWindow():void
		{
			super();

			configChanged = false;
			configChangedLinkages = new Array();
			modsArray = new Array();
		}

		override protected function onPopulate():void
		{
			super.onPopulate();

			App.stage.addEventListener(Event.RESIZE, updatePositions);
			App.gameInputMgr.setKeyHandler(Keyboard.ESCAPE, KeyboardEvent.KEY_DOWN, onEscapeKeyDownHandler, true);

			header.addEventListener(InteractiveEvent.BUTTON_CLOSE_CLICK, handleButtonClose);

			content.addEventListener(InteractiveEvent.SETTINGS_CHANGED, handleModSettingsChanged);
			content.addEventListener(InteractiveEvent.BUTTON_CLICK, handleModSettingsButtonClick);
			content.addEventListener(InteractiveEvent.HOTKEY_ACTION, handleModSettingsHotkeyAction);

			footer.addEventListener(InteractiveEvent.BUTTON_OK_CLICK, handleButtonOK);
			footer.addEventListener(InteractiveEvent.BUTTON_CANCEL_CLICK, handleButtonCancel);
			footer.addEventListener(InteractiveEvent.BUTTON_APPLY_CLICK, handleButtonApply);

			updatePositions();
			requestModsData();
		}

		override protected function onDispose():void
		{
			App.stage.removeEventListener(Event.RESIZE, updatePositions);
			App.gameInputMgr.clearKeyHandler(Keyboard.ESCAPE, KeyboardEvent.KEY_DOWN, onEscapeKeyDownHandler);
			App.toolTipMgr.hide();

			footer.removeEventListener(InteractiveEvent.BUTTON_OK_CLICK, handleButtonOK);
			footer.removeEventListener(InteractiveEvent.BUTTON_CANCEL_CLICK, handleButtonCancel);
			footer.removeEventListener(InteractiveEvent.BUTTON_APPLY_CLICK, handleButtonApply);

			content.removeEventListener(InteractiveEvent.SETTINGS_CHANGED, handleModSettingsChanged);
			content.removeEventListener(InteractiveEvent.BUTTON_CLICK, handleModSettingsButtonClick);
			content.removeEventListener(InteractiveEvent.HOTKEY_ACTION, handleModSettingsHotkeyAction);

			header.removeEventListener(InteractiveEvent.BUTTON_CLOSE_CLICK, handleButtonClose);

			header = null;
			content = null;
			footer = null;
			background = null;

			super.onDispose();
		}

		private function updatePositions(event:Event = null):void
		{
			var appWidth:Number = App.appWidth;
			var appHeight:Number = App.appHeight;

			background.updateStage(appWidth, appHeight);
			header.updateStage(appWidth, appHeight);
			content.updateStage(appWidth, appHeight);
			footer.updateStage(appWidth, appHeight);
		}

		public function as_setStaticData(data:Object):void
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
				var mod:ModsSettingsComponent = new ModsSettingsComponent(linkage);

				mod.setData(modsData[linkage]);
				mod.validateNow();

				mod.y = lastPos;
				lastPos = mod.y + mod.height + Constants.MOD_MARGIN_BOTTOM;

				content.container.addChild(mod);
				modsArray.push(mod);
			}
		}

		public function as_updateHotKeys(data:Object):void
		{
			for each (var mod:ModsSettingsComponent in modsArray)
			{
				if (data.hasOwnProperty(mod.modLinkage))
				{
					for each (var component:Object in mod.components)
					{
						if (component.data.hasOwnProperty('varName') && component.data.varName in data[mod.modLinkage])
						{
							var hotkeyData:Object = data[mod.modLinkage][component.data.varName];
							var hotkeyControlVO:Object = new HotkeyControlVO(hotkeyData);

							component.componentObject['control'].updateData(hotkeyControlVO);
						}
					}
				}
			}
		}

		private function collectModsData():Object
		{
			var result:Object = new Object();

			for each (var mod:ModsSettingsComponent in modsArray)
			{
				if (configChangedLinkages.indexOf(mod.modLinkage) != -1)
				{
					result[mod.modLinkage] = mod.getConfigData();
				}
			}

			return result;
		}

		private function syncModsData():void
		{
			var config:Object = collectModsData();

			sendModsData(App.utils.JSON.encode(config));
		}

		private function handleModSettingsChanged(event:InteractiveEvent):void
		{
			configChanged = true;
			footer.buttonApply.enabled = true;

			if (configChangedLinkages.indexOf(event.linkage) == -1)
				configChangedLinkages.push(event.linkage);
		}

		private function handleModSettingsButtonClick(event:InteractiveEvent):void
		{
			buttonAction(event.linkage, event.varName, event.value);
		}

		private function handleModSettingsHotkeyAction(event:InteractiveEvent):void
		{
			hotKeyAction(event.linkage, event.varName, event.value);
		}

		private function handleButtonOK(event:InteractiveEvent):void
		{
			if (configChanged)
				syncModsData();

			closeView();
		}

		private function handleButtonApply(event:InteractiveEvent):void
		{
			syncModsData();
			configChanged = false;
			footer.buttonApply.enabled = false;
		}

		private function handleButtonCancel(event:InteractiveEvent):void
		{
			closeView();
		}

		private function handleButtonClose(event:InteractiveEvent):void
		{
			closeView();
		}

		private function onEscapeKeyDownHandler(event:InputEvent):void
		{
			closeView();
		}
	}
}
