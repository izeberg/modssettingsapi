package poliroid.gui.lobby.modsSettings
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	import scaleform.clik.events.InputEvent;
	import net.wg.infrastructure.base.AbstractView;

	import poliroid.gui.lobby.modsSettings.components.ModsSettingsWindowRenderer;
	import poliroid.gui.lobby.modsSettings.components.ModsSettingsWindowBackground;
	import poliroid.gui.lobby.modsSettings.components.ModsSettingsWindowContent;
	import poliroid.gui.lobby.modsSettings.components.ModsSettingsWindowFooter;
	import poliroid.gui.lobby.modsSettings.components.ModsSettingsWindowHeader;
	import poliroid.gui.lobby.modsSettings.data.HotkeyControlVO;
	import poliroid.gui.lobby.modsSettings.data.ModsSettingsLocalizationVO;
	import poliroid.gui.lobby.modsSettings.events.InteractiveEvent;
	import poliroid.gui.lobby.modsSettings.lang.STRINGS;
	import poliroid.gui.lobby.modsSettings.shared.Constants;

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
		public var linkAction:Function;
		public var closeView:Function;

		private var modifications:Array;
		private var templates:Object;
		private var dirty:Boolean = false;
		private var dirtyLinkages:Array;

		public function ModsSettingsWindow():void
		{
			super();

			dirty = false;
			dirtyLinkages = new Array();
			modifications = new Array();
		}

		override protected function onPopulate():void
		{
			super.onPopulate();

			App.gameInputMgr.setKeyHandler(Keyboard.ESCAPE, KeyboardEvent.KEY_DOWN, onEscapeKeyDownHandler, true);

			header.addEventListener(InteractiveEvent.CLOSE_BUTTON_CLICK, handleCloseButtonClick);

			content.addEventListener(InteractiveEvent.SETTINGS_CHANGED, handleModsSettingsChanged);
			content.addEventListener(InteractiveEvent.BUTTON_CLICK, handleModsSettingsButtonClick);
			content.addEventListener(InteractiveEvent.LINK_CLICK, handleModsSettingsLinkClick);
			content.addEventListener(InteractiveEvent.HOTKEY_ACTION, handleModsSettingsHotkeyAction);

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

			content.removeEventListener(InteractiveEvent.SETTINGS_CHANGED, handleModsSettingsChanged);
			content.removeEventListener(InteractiveEvent.BUTTON_CLICK, handleModsSettingsButtonClick);
			content.removeEventListener(InteractiveEvent.LINK_CLICK, handleModsSettingsLinkClick);
			content.removeEventListener(InteractiveEvent.HOTKEY_ACTION, handleModsSettingsHotkeyAction);

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
				var modification:ModsSettingsWindowRenderer = content.addModification(template);

				modifications.push(modification);
			}
		}

		public function as_setHotkeys(hotkeys:Object):void
		{
			for (var linkage:String in hotkeys)
			{
				var modification:ModsSettingsWindowRenderer = getModificationByLinkage(linkage);
				if (!modification) continue;

				for (var varName:String in hotkeys[linkage])
				{
					var component:Object = modification.getComponent(varName);
					if (!component) continue;

					var data:Object = hotkeys[linkage][varName];
					var vo:Object = new HotkeyControlVO(data);

					component.instance['control'].setData(vo);
				}
			}
		}

		public function getModificationByLinkage(linkage:String):ModsSettingsWindowRenderer
		{
			if (!linkage) return null;

			for each (var modification:ModsSettingsWindowRenderer in modifications)
			{
				if (linkage == modification.linkage) return modification;
			}

			return null;
		}

		private function collectModsSettings():Object
		{
			var settings:Object = new Object();

			for each (var modification:ModsSettingsWindowRenderer in modifications)
			{
				var linkage:String = modification.linkage;

				if (dirtyLinkages.indexOf(linkage) != -1)
					settings[linkage] = modification.getSettingsSnapshot();
			}

			return settings;
		}

		private function syncModsSettings():void
		{
			var settings:Object = collectModsSettings();

			sendModsData(App.utils.JSON.encode(settings));
		}

		private function handleModsSettingsChanged(event:InteractiveEvent):void
		{
			dirty = true;
			footer.applyButton.enabled = true;

			if (dirtyLinkages.indexOf(event.linkage) == -1)
				dirtyLinkages.push(event.linkage);
		}

		private function handleModsSettingsButtonClick(event:InteractiveEvent):void
		{
			buttonAction(event.linkage, event.varName, event.value);
		}

		private function handleModsSettingsHotkeyAction(event:InteractiveEvent):void
		{
			hotkeyAction(event.linkage, event.varName, event.value);
		}

		private function handleModsSettingsLinkClick(event:InteractiveEvent):void
		{
			linkAction(event.linkage, event.varName, event.value);
		}

		private function handleOkButtonClick(event:InteractiveEvent):void
		{
			if (dirty)
				syncModsSettings();

			closeView();
		}

		private function handleApplyButtonClick(event:InteractiveEvent):void
		{
			syncModsSettings();
			dirty = false;
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
