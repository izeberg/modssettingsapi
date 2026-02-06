package poliroid.gui.lobby.modsSettings.events
{
	import flash.events.Event;

	public class InteractiveEvent extends Event
	{
		public static const HOTKEY_ACTION:String = 'hotkeyAction';
		public static const BUTTON_CLICK:String = 'buttonAction';
		public static const LINK_CLICK:String = 'linkClick';
		public static const SETTINGS_CHANGED:String = 'onModSettingsChanged';
		public static const VALUE_CHANGED:String = 'onValueChanged';
		public static const OK_BUTTON_CLICK:String = 'okButtonClick';
		public static const CANCEL_BUTTON_CLICK:String = 'сancelButtonClick';
		public static const APPLY_BUTTON_CLICK:String = 'applyButtonClick';
		public static const CLOSE_BUTTON_CLICK:String = 'closeButtonClick';

		private var _linkage:String = '';
		private var _varName:String = '';
		private var _value:* = null;

		public function InteractiveEvent(type:String, linkage:String = '', varName:String = '', value:* = null, bubbles:Boolean = true, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			_linkage = linkage;
			_varName = varName;
			_value = value;
		}

		override public function clone():Event
		{
			return new InteractiveEvent(type, _linkage, _varName, _value, bubbles, cancelable);
		}

		public function get linkage():String
		{
			return _linkage;
		}

		public function get varName():String
		{
			return _varName;
		}

		public function get value():*
		{
			return _value;
		}
	}
}
