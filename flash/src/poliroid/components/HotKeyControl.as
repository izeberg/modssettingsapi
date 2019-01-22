package poliroid.components {
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.utils.Timer;
	import flash.geom.Point;
	import poliroid.utils.Logger;
	import scaleform.clik.controls.Label;
	
	import scaleform.clik.controls.ScrollingList;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.ListEvent;
	
	
	import net.wg.data.constants.Linkages;
	import net.wg.data.daapi.ContextMenuOptionVO
	import net.wg.infrastructure.interfaces.IContextItem;
	import net.wg.gui.components.controls.ContextMenu;
	import net.wg.gui.components.controls.LabelControl;
	import net.wg.infrastructure.interfaces.IContextMenu;
	import net.wg.infrastructure.interfaces.entity.IDisposable;
	 
	import poliroid.events.ComponentEvent;
	import poliroid.utils.*;
	import poliroid.utils.ComponentsHelper;
	import poliroid.views.lobby.ModsSettingsApi;

	public class HotKeyControl extends UIComponent {
		
		[Embed(source="../../../res/modsSettingsApi/keyInputNormal.png")]
		private static var keyInputNormalImage:Class;
		[Embed(source="../../../res/modsSettingsApi/keyInputHovered.png")]
		private static var keyInputHoveredImage:Class;
		[Embed(source="../../../res/modsSettingsApi/keyInputPressed.png")]
		private static var keyInputPressedImage:Class;
		[Embed(source="../../../res/modsSettingsApi/keyInputAcceptKey.png")]
		private static var keyInputAcceptKeyImage:Class;
		[Embed(source="../../../res/modsSettingsApi/keyInputNoKey.png")]
		private static var keyInputNoKeyImage:Class;
		[Embed(source="../../../res/modsSettingsApi/keyInputModifiersAlt.png")]
		private static var keyInputModifiersAltImage:Class;
		[Embed(source="../../../res/modsSettingsApi/keyInputModifiersCtrl.png")]
		private static var keyInputModifiersCtrlImage:Class;
		[Embed(source="../../../res/modsSettingsApi/keyInputModifiersShift.png")]
		private static var keyInputModifiersShiftImage:Class;
		
		private var keyInputNormal:Bitmap;
		private var keyInputHovered:Bitmap;
		private var keyInputPressed:Bitmap;
		private var keyInputAcceptKey:Bitmap;
		private var keyInputNoKey:Bitmap;
		
		public var is_pressed:Boolean = false;
		public var is_hovered:Boolean = false;
		public var is_accepting:Boolean = false;
		public var is_setted:Boolean = false;
		
		private var animTimer:Timer;
		private var animVector:Number = 0;
		private var elements:Array;
		private var modifiers:Object;
		
		public var _contextMenu:ContextMenu = null;
		private var keyName:LabelControl;
		private var KeyHolder:UIComponent;
		
		public var is_alt:Boolean = false;
		public var is_control:Boolean = false;
		public var is_shift:Boolean = false;
		public var latestData:Object;
		public var keySet:Array = [];
		private var modLinkage:String;
		private var varName:String;
      
		public function HotKeyControl(modLinkage:String, varName:String, headerText:String = "", tooltipText:String = "") {
			
			super();
			
			try {
				
				if (headerText)
				{
					var lb:DisplayObject = ComponentsHelper.createLabel(headerText, tooltipText);
					lb.x = 0;
					lb.y = 4;
					this.addChild(lb);
				}
				
				this.modLinkage = modLinkage;
				this.varName = varName;
				
				this.keyInputNormal = new keyInputNormalImage();
				this.keyInputHovered = new keyInputHoveredImage();
				this.keyInputPressed = new keyInputPressedImage();
				this.keyInputAcceptKey = new keyInputAcceptKeyImage();
				this.keyInputNoKey = new keyInputNoKeyImage();
				this.keyInputNormal.visible = false;
				this.keyInputHovered.visible = false;
				this.keyInputPressed.visible = false;
				this.keyInputAcceptKey.visible = false;
				this.keyInputNoKey.visible = false;
				
				this.keyName = App.utils.classFactory.getComponent("LabelControl",LabelControl);
				this.keyName.y = 3;
				this.keyName.width = 60;
				this.keyName.textAlign = "center";
				
				this.KeyHolder = new UIComponent();
				this.KeyHolder.buttonMode = true;
				this.KeyHolder.useHandCursor = true;
				this.KeyHolder.y = 0;
				this.KeyHolder.x = 310;
				this.KeyHolder.width = 60;
				this.KeyHolder.height = 25;
				this.KeyHolder.addChild(this.keyInputNormal);
				this.KeyHolder.addChild(this.keyInputHovered);
				this.KeyHolder.addChild(this.keyInputPressed);
				this.KeyHolder.addChild(this.keyInputAcceptKey);
				this.KeyHolder.addChild(this.keyInputNoKey);
				this.KeyHolder.addChild(this.keyName);
				
				
				
				var click_mask:MovieClip = new MovieClip();
				click_mask.x = 0;
				click_mask.y = 0;
				click_mask.width = 60;
				click_mask.height = 25;
				click_mask.buttonMode = true;
				click_mask.useHandCursor = true;
				click_mask.graphics.beginFill(16711680,0.5);
				click_mask.graphics.drawRect(0,0,60,25);
				click_mask.graphics.endFill();
				
				this.KeyHolder.addChild(click_mask);
				
				this.KeyHolder.addEventListener(MouseEvent.CLICK,this.handleMouseClick);
				this.KeyHolder.addEventListener(MouseEvent.MOUSE_DOWN,this.handleMouseDown);
				this.KeyHolder.addEventListener(MouseEvent.MOUSE_UP,this.handleMouseUp);
				this.KeyHolder.addEventListener(MouseEvent.ROLL_OUT,this.handleMouseRollOut);
				this.KeyHolder.addEventListener(MouseEvent.ROLL_OVER, this.handleMouseRollOver);
				
				this.KeyHolder.addEventListener(MouseEvent.RIGHT_CLICK, this.handleMouseRollOver);
				
				this.addChild(this.KeyHolder);
				
				
				this.elements = new Array();
				this.elements.push(this.keyInputNormal);
				this.elements.push(this.keyInputHovered);
				this.elements.push(this.keyInputPressed);
				
				
				var altmodifier:UIComponent = new UIComponent();
				altmodifier.visible = false;
				altmodifier.width = 39;
				altmodifier.height = 25;
				altmodifier.addChild(new keyInputModifiersAltImage());
				altmodifier.validateNow();
				this.addChild(altmodifier);
				
				var ctrlmodifier:UIComponent = new UIComponent();
				ctrlmodifier.visible = false;
				ctrlmodifier.width = 45;
				ctrlmodifier.height = 25;
				ctrlmodifier.addChild(new keyInputModifiersCtrlImage());
				ctrlmodifier.validateNow();
				this.addChild(ctrlmodifier);
				
				var shiftmodifier:UIComponent = new UIComponent();
				shiftmodifier.visible = false;
				shiftmodifier.width = 52;
				shiftmodifier.height = 25;
				shiftmodifier.addChild(new keyInputModifiersShiftImage());
				shiftmodifier.validateNow();
				this.addChild(shiftmodifier);
				
				this.modifiers = {
					ALT: altmodifier,
					CTRL: ctrlmodifier,
					SHIFT: shiftmodifier
				}
				
				this.updateVisibility();
				
				this.animTimer = new Timer(80);
				this.animTimer.addEventListener(TimerEvent.TIMER, this.playAnimFrame);
				
				
			} catch (err:Error) {
				
				Logger.ErrorLog("HotKeyControl", err.message);
				
			}	
		}
		
		public function updateSettings(isFirst:Boolean, data:Object) : void {
			
			try {
				
				this.latestData = data;
				
				if(isFirst) {
					
					this.keySet = data.value;
					this.is_setted = data.is_setted;
					this.is_alt = data.is_alt;
					this.is_control = data.is_control;
					this.is_shift = data.is_shift;
					this.is_accepting = false;
					this.keyName.text = data.button_text;
					
					
				} else if (this.is_setted != data.is_setted || this.is_alt != data.is_alt || this.is_control != data.is_control || this.is_shift != data.is_shift || this.keySet != data.value) {
					
					this.is_setted = data.is_setted;
					this.is_alt = data.is_alt;
					this.is_control = data.is_control;
					this.is_shift = data.is_shift;
					
					this.keySet = data.value;
					
					if (this.modLinkage + this.varName != data.accepting) {
						this.is_accepting = false;
						this.keyName.text = data.button_text;
						this.parent.dispatchEvent(new ComponentEvent(ComponentEvent.VALUE_CHANGED,true));
					}
				
				}
				
				this.updateVisibility();
				
			} catch (err:Error) {
				
				Logger.ErrorLog("HotKeyControl::updateSettings", err.message);
				
			}
		}

		private function handleMouseClick(event:MouseEvent) : void {
			
			if (App.utils.commons.isRightButton(event)) {
				
				try {
					this.hidePopUp();
					this.is_accepting = false;
					this.keyName.text = this.latestData.button_text;
					this.updateVisibility();
					this._contextMenu = App.utils.classFactory.getComponent("ContextMenu", ContextMenu);
					var options:Vector.<IContextItem> = new Vector.<IContextItem>();
					options.push( new ContextMenuOptionVO( { id:0, label:"По умолчанию", initData: 0, submenu: [] } ));
					options.push( new ContextMenuOptionVO( { id:1, label:"Очистить", initData: 1, submenu: [] } ));
					App.utils.popupMgr.show(this._contextMenu, event.stageX, event.stageY);
					var clickPoint:Point = new Point(event.stageX - 65, event.stageY + 30);
					clickPoint.x = clickPoint.x / App.appScale >> 0;
					clickPoint.y = clickPoint.y / App.appScale >> 0;
					this._contextMenu.build(options, clickPoint);
					this._contextMenu.onItemSelectCallback = this.handleMenuItemClick;
					this._contextMenu.onReleaseOutsideCallback = this.hidePopUp;
					this._contextMenu.stage.addEventListener(Event.RESIZE, this.hidePopUp);
				} catch (err:Error) {
					Logger.ErrorLog("HotKeyControl::handleMouseClick", err.message);
				}
			}
			
			if (App.utils.commons.isLeftButton(event)) {
				this.is_accepting = true;
				this.keyName.text = "";
				this.updateVisibility();
				this.animTimer.start();
				ModsSettingsApi.proxy.handleHotKeysS(this.modLinkage, this.varName, "accept");
				return;
			}
		}

		private function handleMenuItemClick(event:String) : void {
			
			this.hidePopUp();
			
			if (event == "0") {
				ModsSettingsApi.proxy.handleHotKeysS(this.modLinkage, this.varName, "default");
			}
			
			if (event == "1") {
				ModsSettingsApi.proxy.handleHotKeysS(this.modLinkage, this.varName, "clear");
			}
			
		}
		
		public function hidePopUp() : void {
			
			if (this._contextMenu != null) {
				var _cmdo :DisplayObject = DisplayObject(this._contextMenu);
				if (_cmdo.stage && _cmdo.stage.hasEventListener(Event.RESIZE)) {
					_cmdo.stage.removeEventListener(Event.RESIZE, this.hidePopUp);
				}
				if (this._contextMenu is IDisposable) {
					IDisposable(this._contextMenu).dispose();
				}
				
				App.utils.popupMgr.popupCanvas.removeChild(this._contextMenu);
				
				this._contextMenu = null;
			}
			
		}
		
		private function handleMouseRollOver(event:MouseEvent) : void {
			this.is_hovered = true;
			this.updateVisibility();
		}

		private function handleMouseRollOut(event:MouseEvent) : void {
			this.is_hovered = false;
			this.is_pressed = false;
			this.updateVisibility();
		}

		private function handleMouseDown(event:MouseEvent) : void {
			this.is_pressed = true;
			this.is_hovered = true;
			this.updateVisibility();
		}

		private function handleMouseUp(event:MouseEvent) : void {
			this.is_pressed = false;
			this.updateVisibility();
		}
		
		private function updateVisibility() : void {
			
			var for_show:Bitmap = null;
			
			if(this.is_pressed) {
				for_show = this.keyInputPressed;
			} else if(this.is_hovered) {
				for_show = this.keyInputHovered;
			} else {
				for_show = this.keyInputNormal;
			}
			
			var offset:Number = 0;
			
			if (this.is_alt) {
				offset = offset + 39;
				this.modifiers.ALT.visible = true;
				this.modifiers.ALT.x = this.KeyHolder.x - offset;
			} else {
				this.modifiers.ALT.visible = false;
			}
			
			if (this.is_control) {
				offset = offset + 45;
				this.modifiers.CTRL.visible = true;
				this.modifiers.CTRL.x = this.KeyHolder.x - offset;
			} else {
				this.modifiers.CTRL.visible = false;
			}
			
			if (this.is_shift) {
				offset = offset + 52;
				this.modifiers.SHIFT.visible = true;
				this.modifiers.SHIFT.x = this.KeyHolder.x - offset;
			} else {
				this.modifiers.SHIFT.visible = false;
			}
			
			
			for_show.visible = true;
			
			this.keyInputAcceptKey.visible = this.is_accepting;
			this.keyInputNoKey.visible = this.is_accepting?false:!this.is_setted;
			
			for (var key:String in this.elements) {
				if(this.elements[key] != for_show) this.elements[key].visible = false;
			}
		}
		
		private function playAnimFrame() : void {
			if (this.is_accepting) {
				if (this.animVector == 0) {
					this.keyInputAcceptKey.alpha = this.keyInputAcceptKey.alpha - 0.1;
					if(this.keyInputAcceptKey.alpha < 0.2) this.animVector = 1;
				}
				if (this.animVector == 1) {
					this.keyInputAcceptKey.alpha = this.keyInputAcceptKey.alpha + 0.1;
					if(this.keyInputAcceptKey.alpha >= 1) this.animVector = 0;
				}
			} else {
				this.animTimer.stop();
			}
		}
	}
}
