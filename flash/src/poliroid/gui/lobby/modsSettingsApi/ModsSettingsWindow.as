package poliroid.gui.lobby.modsSettingsApi
{
	
	/*
	import poliroid.events.LoggerEvent;

	import poliroid.utils.Constants;
	import poliroid.utils.Logger;
	import org.idmedia.as3commons.lang.NullPointerException;
	import poliroid.components.*;
	import poliroid.components.lobby.ModsSettingsApiComponent;
	import poliroid.events.*;
	import poliroid.lang.*;
	import poliroid.events.ModsSettingsApiComponentEvent;
	import poliroid.utils.*;
	import flash.display.*;
	import flash.events.*;
	import net.wg.gui.components.controls.*;
	import net.wg.infrastructure.base.*;	
	*/
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import net.wg.infrastructure.base.AbstractView;
	import net.wg.infrastructure.base.AbstractWindowView;
	import net.wg.gui.components.controls.ScrollPane;
	import net.wg.gui.components.controls.ScrollBar;
	import net.wg.gui.components.controls.SoundButton;
	
	import poliroid.gui.lobby.modsSettingsApi.components.ModApiComponent;
	import poliroid.gui.lobby.modsSettingsApi.lang.LANGUAGES;
	import poliroid.gui.lobby.modsSettingsApi.lang.STRINGS;
	import poliroid.gui.lobby.modsSettingsApi.events.InteractiveEvent;
	import poliroid.gui.lobby.modsSettingsApi.utils.Constants;

	public class ModsSettingsWindow extends AbstractWindowView
	{
		
		public var scrollPane:ScrollPane;
		public var scrollBar:ScrollBar;
		public var modsContainer:MovieClip;
		public var modsArray:Array;
		public var modsData:Object;
		
		public var requestModsDataS:Function = null;
		public var sendModsDataS:Function = null;
		public var callButtonsS:Function = null;
		public var handleHotKeysS:Function = null;
		
		public var currentLang:Object;
		public var btnOk:SoundButton;
		public var btnCancel:SoundButton;
		public var btnApply:SoundButton;
		private var configChanged:Boolean;
		private var configChangedLinkages:Array;
		
		public function ModsSettingsWindow() : void
		{
			super();
			
			currentLang = LANGUAGES.RU;
			configChanged = false;
			configChangedLinkages = new Array();
			modsArray = new Array();
			
			width = 860;
			height = 600;
			canResize = false;
			isCentered = true;
		}
		
		override protected function onPopulate() : void
		{
			super.onPopulate();
			
			STRINGS.setLang(currentLang);
			
			window.useBottomBtns = true;
			
			btnApply.enabled = configChanged;
			btnOk.addEventListener(MouseEvent.CLICK, handleBtnOkClick);
			btnCancel.addEventListener(MouseEvent.CLICK, handleWindowClose);
			btnApply.addEventListener(MouseEvent.CLICK, handleBtnApplyClick);
			
			window.title = STRINGS.WINDOW_TITLE;
			btnApply.label = STRINGS.BUTTON_APPLY;
			btnOk.label = STRINGS.BUTTON_OK;
			btnCancel.label = STRINGS.BUTTON_CANCEL
			
			modsContainer = new MovieClip();
			modsContainer.addEventListener(InteractiveEvent.SETTINGS_CHANGED, handleModSettingsChanged);
			modsContainer.addEventListener(InteractiveEvent.BUTTON_CLICK, handleModSettingsButtonClick);
			modsContainer.addEventListener(InteractiveEvent.HOTKEY_ACTION, handleModSettingsHotkeyAction);
			
			scrollPane.scrollStepFactor = 20;
			scrollPane.scrollBar = scrollBar;
			scrollPane.isScrollBarHaveToBeShown = true;
			scrollPane.setSize(850, 570);
			scrollPane.target = modsContainer;

			requestModsDataS();
		}
		
		override protected function onDispose() : void
		{
			App.toolTipMgr.hide();
			
			btnOk.removeEventListener(MouseEvent.CLICK, handleBtnOkClick);
			btnCancel.removeEventListener(MouseEvent.CLICK, handleWindowClose);
			btnApply.removeEventListener(MouseEvent.CLICK, handleBtnApplyClick);
			
			super.onDispose();
		}
		
		public function as_setUserSettings(data:Object) : void
		{
			if (data.windowTitle)
			{
				window.title = data.windowTitle;
			}
			if (data.buttonOK)
			{
				btnOk.label = data.buttonOK;
			}
			if (data.buttonCancel)
			{
				btnCancel.label = data.buttonCancel;
			}
			if (data.buttonApply)
			{
				btnApply.label = data.buttonApply;
			}
			if (data.enableButtonTooltip)
			{
				STRINGS.BUTTON_ENABLED_TOOLTIP = data.enableButtonTooltip;
			}
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
				
				modsContainer.addChild(mod);
				modsArray.push(mod);
			}
		}
		
		public function as_updateHotKeys(hotkeys_data:Object) : void 
		{
			for (var mod_iter:Number = 0; mod_iter < modsArray.length; mod_iter++)
			{
				var mod:ModApiComponent = modsArray[mod_iter];
				if (mod.modLinkage in hotkeys_data)
				{
					for (var component_iter:Number = 0; component_iter < mod.components.length; component_iter++)
					{
						var component:Object = mod.components[component_iter];
						if ("varName" in component.data && component.data.varName in hotkeys_data[mod.modLinkage])
						{
							component.componentObject['control'].updateData(hotkeys_data[mod.modLinkage][component.data.varName]);
						}
					}
				}
			}
		}
		
		private function collectModsData():Object
		{
			var result:Object = new Object();
		
			for (var i:Number = 0; i < modsArray.length; i++)
			{
				var mod:ModApiComponent = modsArray[i];
				if (configChangedLinkages.indexOf(mod.modLinkage) != -1)
				{
					result[mod.modLinkage] = mod.getConfigData();
				}
			}
			return result;
		}
		
		private function handleBtnOkClick(event:MouseEvent):void
		{
			if(configChanged) {
				var config:Object = collectModsData();
				sendModsDataS(App.utils.JSON.encode(config));
			}			
			handleWindowClose();
		}
		
		private function handleBtnApplyClick(event:MouseEvent):void
		{
			var config:Object = collectModsData();
			sendModsDataS(App.utils.JSON.encode(config));
			configChanged = false;
			btnApply.enabled = configChanged;
		}
		
		private function handleModSettingsChanged(event:InteractiveEvent):void
		{
			configChanged = true;
			btnApply.enabled = true;
			btnOk.enabled = true;
			if (configChangedLinkages.indexOf(event.linkage) == -1)
			{
				configChangedLinkages.push(event.linkage);
			}
		}
		
		private function handleModSettingsButtonClick(event:InteractiveEvent):void
		{
			callButtonsS(event.linkage, event.varName, event.value);
		}
		
		private function handleModSettingsHotkeyAction(event:InteractiveEvent):void
		{
			handleHotKeysS(event.linkage, event.varName, event.value);
		}
	}
}