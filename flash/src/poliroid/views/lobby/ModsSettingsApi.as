package poliroid.views.lobby
{
	import poliroid.events.LoggerEvent;
	import poliroid.lang.LANGUAGES;
	import poliroid.lang.STRINGS;
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
	
	public class ModsSettingsApi extends AbstractWindowView
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
		public var flashLogS:Function = null;
		
		public var currentLang:Object;
		public var btnOk:SoundButton;
		public var btnCancel:SoundButton;
		public var btnApply:SoundButton;
		private var configChanged:Boolean;
		private var configChangedLinkages:Array;
		
		static public var proxy:ModsSettingsApi = null;
		
		public function ModsSettingsApi():void
		{
			super();
			this.currentLang = LANGUAGES.RU;
			this.configChanged = false;
			this.configChangedLinkages = new Array();
			this.modsArray = new Array();
			
			this.btnOk = App.utils.classFactory.getComponent("ButtonNormal", SoundButton);
			this.addChild(this.btnOk);
			this.btnCancel = App.utils.classFactory.getComponent("ButtonNormal", SoundButton);
			this.addChild(this.btnCancel);
			this.btnApply = App.utils.classFactory.getComponent("ButtonNormal", SoundButton);
			this.addChild(this.btnApply);
			this.scrollBar = App.utils.classFactory.getComponent("ScrollBar", ScrollBar);
			this.addChild(this.scrollBar);
			
			this.width = 860;
			this.height = 600;
			//this.canDrag = false;
			this.canResize = false;
			//this.isModal = true;
			this.isCentered = true;
			//this.canClose = true;
			
			proxy = this;
			
		}
		
		public function handleLoggerEvent(event:LoggerEvent) : void {
			this.flashLogS(event.data);
		}
		
		override protected function onPopulate() : void {
			
			super.onPopulate();
			STRINGS.setLang(this.currentLang);
			this.window.useBottomBtns = true;
			
			this.btnApply.enabled = this.configChanged;
			this.btnOk.addEventListener(MouseEvent.CLICK, this.handleBtnOkClick);
			this.btnCancel.addEventListener(MouseEvent.CLICK, this.handleWindowClose);
			this.btnApply.addEventListener(MouseEvent.CLICK, this.handleBtnApplyClick);
			
			this.btnApply.width = this.btnCancel.width = this.btnOk.width = 100;
			this.btnApply.x = 860 - this.btnApply.width - 5;
			this.btnCancel.x = this.btnApply.x - 105;
			this.btnOk.x = this.btnCancel.x - 105;
			this.btnApply.y = this.btnCancel.y = this.btnOk.y = 580;
			
			this.refreshStrings();
			this.requestModsDataS();
		}
		
		override protected function onDispose():void
		{
			Logger.DebugLog("ModSettingsAPIWindow::onDispose");
			App.toolTipMgr.hide();
			this.btnOk.removeEventListener(MouseEvent.CLICK, this.handleBtnOkClick);
			this.btnCancel.removeEventListener(MouseEvent.CLICK, this.handleWindowClose);
			this.btnApply.removeEventListener(MouseEvent.CLICK, this.handleBtnApplyClick);
			super.onDispose();
		}
		
		public function as_setUserSettings(data:Object):void
		{
			try
			{
				if (data.windowTitle)
				{
					this.window.title = data.windowTitle;
				}
				if (data.buttonOK)
				{
					this.btnOk.label = data.buttonOK;
				}
				if (data.buttonCancel)
				{
					this.btnCancel.label = data.buttonCancel;
				}
				if (data.buttonApply)
				{
					this.btnApply.label = data.buttonApply;
				}
				if (data.enableButtonTooltip)
				{
					STRINGS.BUTTON_ENABLED_TOOLTIP = data.enableButtonTooltip;
				}
			}
			catch (err:Error)
			{
				Logger.ErrorLog("ModSettingsAPIWindow::as_setUserSettings", err.message);
			}
		}
		
		public function as_setData(data:Object):void
		{
			try
			{
				this.initScrollArea();
				this.modsData = data;
				var lastPos:int = 0;
				for (var linkage:String in this.modsData)
				{
					Logger.DebugLog("as_setData:: Adding mod: " + linkage);
					
					var mod:ModsSettingsApiComponent = new ModsSettingsApiComponent(linkage);
					mod.setData(this.modsData[linkage]);
					mod.validateNow();
					Logger.DebugLog("as_setData:: " + linkage + "post_validate actualHeight: " + mod.actualHeight + " height: " + mod.height);
					mod.y = lastPos;
					lastPos = mod.y + mod.height + Constants.MOD_MARGIN_BOTTOM;
					//mod.height = mod.actualHeight + 20;
					
					this.modsContainer.addChild(mod);
					this.modsArray.push(mod);
					
					Logger.DebugLog("as_setData:: " + linkage + " lastPos: " + lastPos);
				}
			}
			catch (err:Error)
			{
				Logger.ErrorLog("ModSettingsAPIWindow::as_setData", err.message);
			}
		}
		
		
		public function as_updateHotKeys(hotkeys_data:Object, isFirst:Boolean):void 
		{
			try
			{
				for (var mod_iter:Number = 0; mod_iter < this.modsArray.length; mod_iter++) {
					var mod:ModsSettingsApiComponent = this.modsArray[mod_iter];
					if (mod.modLinkage in hotkeys_data) {
						for (var component_iter:Number = 0; component_iter < mod.components.length; component_iter++) {
							var component:Object = mod.components[component_iter];
							if ("varName" in component.data && component.data.varName in hotkeys_data[mod.modLinkage]) {
								component.componentObject['control'].updateSettings(isFirst, hotkeys_data[mod.modLinkage][component.data.varName]);
							}
						}
					}
				}
			}
			catch (err:Error)
			{
				Logger.ErrorLog("ModSettingsAPIWindow::as_updateHotKeys", err.message);
			}
		}
		
		
		private function handleModSettingsChanged(event:ModsSettingsApiComponentEvent):void
		{
			this.configChanged = true;
			this.btnApply.enabled = true;
			this.btnOk.enabled = true;
			if (this.configChangedLinkages.indexOf(event.modLinkage) == -1)
			{
				this.configChangedLinkages.push(event.modLinkage);
			}
			Logger.DebugLog("ModSettingsAPIWindow::handleModSettingsChanged " + event.modLinkage);
		}
		
		private function handleBtnOkClick(event:MouseEvent):void
		{
			if(this.configChanged) {
				var config:Object = this.collectModsData();
				this.sendModsDataS(App.utils.JSON.encode(config));
			}			
			this.handleWindowClose();
		}
		
		private function handleBtnApplyClick(event:MouseEvent):void
		{
			var config:Object = this.collectModsData();
			this.sendModsDataS(App.utils.JSON.encode(config));
			this.configChanged = false;
			this.btnApply.enabled = this.configChanged;
			//this.btnOk.enabled = this.configChanged;
		}
		
		private function collectModsData():Object
		{
			var result:Object = new Object();
			try
			{
				for (var i:Number = 0; i < this.modsArray.length; i++)
				{
					var mod:ModsSettingsApiComponent = this.modsArray[i];
					if (this.configChangedLinkages.indexOf(mod.modLinkage) != -1)
					{
						Logger.DebugLog("collectModsData:: Collecting mod data: " + mod.modLinkage);
						result[mod.modLinkage] = mod.getConfigData();
					}
				}
				return result;
			}
			catch (err:Error)
			{
				Logger.ErrorLog("collectModsData()", err.message);
			}
			return result;
		}
		
		private function initScrollArea():void
		{
			this.scrollPane = new ScrollPane();
			this.modsContainer = new MovieClip();
			this.modsContainer.addEventListener(ModsSettingsApiComponentEvent.MOD_SETTINGS_CHANGED, this.handleModSettingsChanged);
			this.scrollBar.y = 7;
			this.scrollBar.x = 840;
			this.scrollBar.height = 563;
			
			this.scrollPane.scrollStepFactor = 20;
			this.scrollPane.x = this.scrollPane.y = 0;
			this.scrollPane.scrollBar = this.scrollBar;
			this.scrollPane.isScrollBarHaveToBeShown = true;
			this.scrollPane.setSize(850, 570);
			this.scrollPane.target = this.modsContainer;
			this.addChild(this.scrollPane);
			
			this.swapChildren(this.scrollPane, this.scrollBar);
		}
		
		private function refreshStrings():void
		{
			this.window.title = STRINGS.WINDOW_TITLE;
			this.btnApply.label = STRINGS.BUTTON_APPLY;
			this.btnOk.label = STRINGS.BUTTON_OK;
			this.btnCancel.label = STRINGS.BUTTON_CANCEL
		}
	
	}

}