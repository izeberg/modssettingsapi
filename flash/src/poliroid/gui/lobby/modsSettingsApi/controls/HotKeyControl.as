package poliroid.gui.lobby.modsSettingsApi.controls
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	
	import net.wg.gui.components.controls.SoundButtonEx;
	import net.wg.gui.interfaces.ISoundButtonEx;
	
	import poliroid.gui.lobby.modsSettingsApi.data.HotKeyControlVO;
	import poliroid.gui.lobby.modsSettingsApi.events.InteractiveEvent;
	
	public class HotKeyControl extends SoundButtonEx implements ISoundButtonEx
	{
		private static const COMMAND_START_ACCEPT:String = 'startAccept';
		private static const COMMAND_STOP_ACCEPT:String = 'stopAccept';
		
		private static const STATE_ACCEPTING:String = 'accepting';
		private static const STATE_EMPTY:String = 'empty';
		private static const STATE_NORMAL:String = 'normal';
		private static const MODIFIERS_PREFIX:String = 'mod_';
		
		public var valueTF:TextField = null;
		public var statesMC:MovieClip = null;
		public var modifiersMC:MovieClip = null;
		public var keySet:Array = null;
		public var hitAreaA:MovieClip = null;

		private var model:HotKeyControlVO = null;
		
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
		
		public function updateData(data:HotKeyControlVO) : void
		{
			model = data;

			if (keySet && (keySet.toString() != model.keySet.toString()))
			{
				dispatchEvent(new InteractiveEvent(InteractiveEvent.VALUE_CHANGED))
			}
			
			keySet = model.keySet;

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
				valueTF.text = model.text;
			}
			

			var modifiers_label:String = MODIFIERS_PREFIX;
			
			if (model.modifierCtrl)
				modifiers_label += 'ctrl';
			if (model.modifierAlt)
				modifiers_label += 'alt';
			if (model.modiferShift)
				modifiers_label += 'shift';
			
			if (model.isAccepting || model.isEmpty)
				modifiersMC.gotoAndStop(MODIFIERS_PREFIX);
			else
				modifiersMC.gotoAndStop(modifiers_label);
		}
		
		override protected function onMouseDownHandler(event:MouseEvent) : void
		{
			super.onMouseDownHandler(event);
			
			if (App.utils.commons.isLeftButton(event)) 
			{
				if (!model.isAccepting)
				{
					dispatchEvent(new InteractiveEvent(InteractiveEvent.HOTKEY_ACTION, model.linkage, model.varName, COMMAND_START_ACCEPT));
				}
			}
			
			if (App.utils.commons.isRightButton(event)) 
			{
				if (model.isAccepting)
				{
					dispatchEvent(new InteractiveEvent(InteractiveEvent.HOTKEY_ACTION, model.linkage, model.varName, COMMAND_STOP_ACCEPT));
				}

				App.contextMenuMgr.show('modsSettingsHotkeyContextHandler', this, {'linkage': model.linkage,'varName': model.varName});
			}
		}
	}
}