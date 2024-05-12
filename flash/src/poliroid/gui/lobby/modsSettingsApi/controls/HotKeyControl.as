package poliroid.gui.lobby.modsSettingsApi.controls
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import net.wg.gui.components.controls.SoundButtonEx;
	import poliroid.gui.lobby.modsSettingsApi.data.HotkeyControlVO;
	import poliroid.gui.lobby.modsSettingsApi.events.InteractiveEvent;

	public class HotkeyControl extends SoundButtonEx
	{
		private static const COMMAND_START_ACCEPT:String = 'startAccept';
		private static const COMMAND_STOP_ACCEPT:String = 'stopAccept';
		private static const STATE_ACCEPTING:String = 'accepting';
		private static const STATE_EMPTY:String = 'empty';
		private static const STATE_NORMAL:String = 'normal';
		private static const MODIFIERS_PREFIX:String = 'mod_';

		public var valueTF:TextField;
		public var statesMC:MovieClip;
		public var modifiersMC:MovieClip;
		public var hitAreaA:MovieClip;

		private var _model:HotkeyControlVO;
		private var _keyset:Array;

		public function HotkeyControl():void
		{
			super();
		}

		override protected function configUI():void
		{
			super.configUI();

			scaleX = 1;
			scaleY = 1;
			preventAutosizing = true;
			focusable = false;
			hitArea = hitAreaA;
			valueTF.selectable = false;
		}

		public function updateData(data:HotkeyControlVO):void
		{
			_model = data;

			if (_keyset && (_keyset.toString() != _model.keyset.toString()))
				dispatchEvent(new InteractiveEvent(InteractiveEvent.VALUE_CHANGED));

			_keyset = _model.keyset;

			if (_model.isAccepting)
			{
				statesMC.gotoAndPlay(STATE_ACCEPTING);
				valueTF.text = "";
			}
			else if (_model.isEmpty)
			{
				statesMC.gotoAndPlay(STATE_EMPTY);
				valueTF.text = "";
			}
			else
			{
				statesMC.gotoAndStop(STATE_NORMAL);
				valueTF.text = _model.text;
			}

			var modifiersLabel:String = MODIFIERS_PREFIX;

			if (_model.modifierCtrl)
				modifiersLabel += 'ctrl';
			if (_model.modifierAlt)
				modifiersLabel += 'alt';
			if (_model.modiferShift)
				modifiersLabel += 'shift';

			if (_model.isAccepting || _model.isEmpty)
				modifiersMC.gotoAndStop(MODIFIERS_PREFIX);
			else
				modifiersMC.gotoAndStop(modifiersLabel);
		}

		override protected function onMouseDownHandler(event:MouseEvent):void
		{
			super.onMouseDownHandler(event);

			if (App.utils.commons.isLeftButton(event))
			{
				if (!_model.isAccepting)
					dispatchEvent(new InteractiveEvent(InteractiveEvent.HOTKEY_ACTION, _model.linkage, _model.varName, COMMAND_START_ACCEPT));
			}

			if (App.utils.commons.isRightButton(event))
			{
				if (_model.isAccepting)
					dispatchEvent(new InteractiveEvent(InteractiveEvent.HOTKEY_ACTION, _model.linkage, _model.varName, COMMAND_STOP_ACCEPT));

				App.contextMenuMgr.show('modsSettingsHotkeyContextHandler', this, {'linkage': _model.linkage, 'varName': _model.varName});
			}
		}
	}
}