package poliroid.gui.lobby.modsSettingsApi.utils
{
	
	public class ValueProxy
	{
		public var target:*;
		public var key:*;
		
		public function ValueProxy(target:* = null, key:* = null)
		{
			target = target;
			key = key;
		}
		
		public function get value():*
		{
			return key != null ? target[key] : target;
		}
	}
}
