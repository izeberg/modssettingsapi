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
	import poliroid.gui.lobby.modsSettings.data.ModsSettingsLocalizationVO;
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
		public var hotkeyAction:Function;
		public var closeView:Function;

		private var modsArray:Array;
		private var templates:Object;
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

			App.gameInputMgr.setKeyHandler(Keyboard.ESCAPE, KeyboardEvent.KEY_DOWN, onEscapeKeyDownHandler, true);

			header.addEventListener(InteractiveEvent.CLOSE_BUTTON_CLICK, handleCloseButtonClick);

			content.addEventListener(InteractiveEvent.SETTINGS_CHANGED, handleModSettingsChanged);
			content.addEventListener(InteractiveEvent.BUTTON_CLICK, handleModSettingsButtonClick);
			content.addEventListener(InteractiveEvent.HOTKEY_ACTION, handleModSettingsHotkeyAction);

			footer.addEventListener(InteractiveEvent.OK_BUTTON_CLICK, handleOkButtonClick);
			footer.addEventListener(InteractiveEvent.CANCEL_BUTTON_CLICK, handleCancelButtonClick);
			footer.addEventListener(InteractiveEvent.APPLY_BUTTON_CLICK, handleApplyButtonClick);

			requestModsData();
		}

		override protected function onDispose():void
		{
			App.gameInputMgr.clearKeyHandler(Keyboard.ESCAPE, KeyboardEvent.KEY_DOWN, onEscapeKeyDownHandler);
			App.toolTipMgr.hide();

			header.removeEventListener(InteractiveEvent.CLOSE_BUTTON_CLICK, handleCloseButtonClick);

			content.removeEventListener(InteractiveEvent.SETTINGS_CHANGED, handleModSettingsChanged);
			content.removeEventListener(InteractiveEvent.BUTTON_CLICK, handleModSettingsButtonClick);
			content.removeEventListener(InteractiveEvent.HOTKEY_ACTION, handleModSettingsHotkeyAction);

			footer.removeEventListener(InteractiveEvent.OK_BUTTON_CLICK, handleOkButtonClick);
			footer.removeEventListener(InteractiveEvent.CANCEL_BUTTON_CLICK, handleCancelButtonClick);
			footer.removeEventListener(InteractiveEvent.APPLY_BUTTON_CLICK, handleApplyButtonClick);

			header = null;
			content = null;
			footer = null;
			background = null;

			super.onDispose();
		}

		override public function updateStage(width:Number, height:Number):void
		{
			header.updateStage(width, height);
			content.updateStage(width, height);
			footer.updateStage(width, height);
			background.updateStage(width, height);
		}

		public function as_setLocalization(l10n:Object):void
		{
			var vo:ModsSettingsLocalizationVO = new ModsSettingsLocalizationVO(l10n);

			header.setLocalization(vo);
			footer.setLocalization(vo);
			STRINGS.setLocalization(vo);
		}

		public function as_setData(data:Array):void
		{
			templates = data;

			for each (var template:Object in templates)
			{
				var mod:ModsSettingsComponent = content.addMod(template);

				modsArray.push(mod);
			}
		}

		public function as_setHotkeys(data:Object):void
		{
			for each (var mod:ModsSettingsComponent in modsArray)
			{
				var linkage:String = mod.modLinkage;

				if (data.hasOwnProperty(linkage))
				{
					for each (var component:Object in mod.components)
					{
						if (component.data.hasOwnProperty('varName') && component.data.varName in data[linkage])
						{
							var hotkeyData:Object = data[linkage][component.data.varName];
							var hotkeyControlVO:Object = new HotkeyControlVO(hotkeyData);

							component.componentObject['control'].setData(hotkeyControlVO);
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
				var linkage:String = mod.modLinkage;

				if (configChangedLinkages.indexOf(linkage) != -1)
				{
					result[linkage] = mod.getConfigData();
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
			footer.applyButton.enabled = true;

			if (configChangedLinkages.indexOf(event.linkage) == -1)
				configChangedLinkages.push(event.linkage);
		}

		private function handleModSettingsButtonClick(event:InteractiveEvent):void
		{
			buttonAction(event.linkage, event.varName, event.value);
		}

		private function handleModSettingsHotkeyAction(event:InteractiveEvent):void
		{
			hotkeyAction(event.linkage, event.varName, event.value);
		}

		private function handleOkButtonClick(event:InteractiveEvent):void
		{
			if (configChanged)
				syncModsData();

			closeView();
		}

		private function handleApplyButtonClick(event:InteractiveEvent):void
		{
			syncModsData();
			configChanged = false;
			footer.applyButton.enabled = false;
		}

		private function handleCancelButtonClick(event:InteractiveEvent):void
		{
			closeView();
		}

		private function handleCloseButtonClick(event:InteractiveEvent):void
		{
			closeView();
		}

		private function onEscapeKeyDownHandler(event:InputEvent):void
		{
			closeView();
		}
	}
}
