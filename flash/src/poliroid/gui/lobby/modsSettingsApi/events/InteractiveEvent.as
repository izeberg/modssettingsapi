
package poliroid.gui.lobby.modsSettingsApi.events
{
	import flash.events.Event;
	
	public class InteractiveEvent extends Event
	{
		
		public static const HOTKEY_ACTION:String = "hotkeyAction";
		
		public static const BUTTON_CLICK:String = "buttonClick";
		
		public static const SETTINGS_CHANGED:String = "onModSettingsChanged";

		public static const VALUE_CHANGED:String = "onValueChanged";
		
		private var _modLinkage:String = "";
		
		private var _varName:String = "";
		
		private var _value:* = null;
		
		public function InteractiveEvent(type:String, linkage:String = "", varName:String = "", value:* = null, bubbles:Boolean = true, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			_modLinkage = linkage;
			_varName = varName;
			_value = value;
		}
		
		override public function clone() : Event
		{
			return new InteractiveEvent(type, _modLinkage, _varName,_value, bubbles, cancelable);
		}
		
		public function get linkage() : String
		{
			return _modLinkage;
		}
		
		public function get varName() : String
		{
			return _varName;
		}
		
		public function get value() : *
		{
			return _value;
		}
	}
}
