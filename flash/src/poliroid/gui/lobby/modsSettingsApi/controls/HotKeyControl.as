package poliroid.gui.lobby.modsSettingsApi.controls
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	
	import net.wg.data.daapi.ContextMenuOptionVO
	import net.wg.infrastructure.interfaces.IContextMenu;
	import net.wg.gui.components.controls.ContextMenu;
	import net.wg.gui.components.controls.SoundButtonEx;
	import net.wg.gui.interfaces.ISoundButtonEx;
	import net.wg.infrastructure.interfaces.entity.IDisposable;
	import net.wg.infrastructure.interfaces.IContextItem;
	
	import poliroid.gui.lobby.modsSettingsApi.lang.STRINGS;
	import poliroid.gui.lobby.modsSettingsApi.data.HotKeyControlVO;
	import poliroid.gui.lobby.modsSettingsApi.events.InteractiveEvent;
	
	public class HotKeyControl extends SoundButtonEx implements ISoundButtonEx
	{
		private static const COMMAND_START_ACCEPT:String = 'startAccept';
		private static const COMMAND_STOP_ACCEPT:String = 'stopAccept';
		private static const COMMAND_DEFAULT:String = 'default';
		private static const COMMAND_CLEAN:String = 'clean';
		
		private static const STATE_ACCEPTING:String = 'accepting';
		private static const STATE_EMPTY:String = 'empty';
		private static const STATE_NORMAL:String = 'normal';
		
		public var hitAreaA:MovieClip = null;
		public var valueTF:TextField = null;
		public var statesMC:MovieClip = null;
		public var modifiersMC:MovieClip = null;
		
		private var model:HotKeyControlVO = null;
		private var _contextMenu:ContextMenu = null;
		
		public function HotKeyControl() : void 
		{
			super();
		}
		
		override protected function configUI() : void 
		{
			super.configUI();
			scaleX = 1;
			scaleY = 1;
			preventAutosizing = true;
			focusable = false;
			hitArea = hitAreaA;
			valueTF.selectable = false;
		}
		
		public function updateData(ctx:Object) : void
		{
			
			model = new HotKeyControlVO(ctx);
			
			if (model.isAccepting)
			{
				statesMC.gotoAndPlay(STATE_ACCEPTING);
				valueTF.text = "";
			}
			else if (model.isEmpty)
			{
				statesMC.gotoAndPlay(STATE_EMPTY);
				valueTF.text = "";
			}
			else
			{
				statesMC.gotoAndStop(STATE_NORMAL);
				valueTF.text = model.value;
			}
			
			
			var modifiers_label:String = "mod_";
			if (model.modifierCtrl)
			{
				modifiers_label += 'ctrl';
			}
			if (model.modifierAlt)
			{
				modifiers_label += 'alt';
			}
			if (model.modiferShift)
			{
				modifiers_label += 'shift';
			}	
			modifiersMC.gotoAndStop(modifiers_label);
		}
		
		override protected function onMouseDownHandler(e:MouseEvent) : void
		{
			if (App.utils.commons.isLeftButton(e)) 
			{
				if (!model.isAccepting)
				{
					dispatchEvent(new InteractiveEvent(InteractiveEvent.HOTKEY_ACTION, model.linkage, model.varName, COMMAND_START_ACCEPT));
					statesMC.gotoAndPlay(STATE_ACCEPTING);
				}
			}
			
			if (App.utils.commons.isRightButton(e)) 
			{
				if (model.isAccepting)
				{
					dispatchEvent(new InteractiveEvent(InteractiveEvent.HOTKEY_ACTION, model.linkage, model.varName, COMMAND_STOP_ACCEPT));
					if (model.isEmpty)
					{
						statesMC.gotoAndPlay(STATE_EMPTY);
					}
					else
					{
						statesMC.gotoAndStop(STATE_NORMAL);
					}
				}
				
				hidePopUp();
				
				_contextMenu = ContextMenu(App.utils.classFactory.getComponent("ContextMenu", ContextMenu));
				var options:Vector.<IContextItem> = new Vector.<IContextItem>();
				options.push( new ContextMenuOptionVO( { id:0, label: STRINGS.CONTEXT_DEFAULT, initData: 0, submenu: [] } ));
				options.push( new ContextMenuOptionVO( { id:1, label: STRINGS.CONTEXT_CLEAN, initData: 1, submenu: [] } ));
				App.utils.popupMgr.show(_contextMenu, e.stageX, e.stageY);
				
				var clickPoint:Point = new Point(e.stageX - 65, e.stageY + 30);
				clickPoint.x = clickPoint.x / App.appScale >> 0;
				clickPoint.y = clickPoint.y / App.appScale >> 0;
				_contextMenu.build(options, clickPoint);
				_contextMenu.onItemSelectCallback = handleMenuItemClick;
				_contextMenu.onReleaseOutsideCallback = hidePopUp;
				_contextMenu.stage.addEventListener(Event.RESIZE, hidePopUp);
			}
		}
		
		private function hidePopUp() : void
		{
			if (_contextMenu == null)
			{
				return;
			}
			
			var cMenu:DisplayObject = DisplayObject(_contextMenu);
			if (cMenu.stage && cMenu.stage.hasEventListener(Event.RESIZE))
			{
				cMenu.stage.removeEventListener(Event.RESIZE, hidePopUp);
			}
			
			if (_contextMenu is IDisposable)
			{
				IDisposable(_contextMenu).dispose();
			}
				
			App.utils.popupMgr.popupCanvas.removeChild(_contextMenu);
				
			_contextMenu = null;
		}
		
		private function handleMenuItemClick(itemID:String) : void
		{
			hidePopUp();
			
			if (itemID == "0") 
			{
				dispatchEvent(new InteractiveEvent(InteractiveEvent.HOTKEY_ACTION, model.linkage, model.varName, COMMAND_DEFAULT));
			}
			else if (itemID == "1") 
			{
				dispatchEvent(new InteractiveEvent(InteractiveEvent.HOTKEY_ACTION, model.linkage, model.varName, COMMAND_CLEAN));
			}
		}
	}
}