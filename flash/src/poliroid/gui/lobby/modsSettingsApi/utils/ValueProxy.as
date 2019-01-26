package poliroid.gui.lobby.modsSettingsApi.utils
{
	
	public class ValueProxy
	{
		public var target:*;
		public var key:*;
		
		public function ValueProxy(target:*, key:*)
		{
			if (!target) throw new Error("Wrong target");
			if (!key) throw new Error("Wrong key");
			this.target = target;
			this.key = key;
		}
		
		public function get value():*
		{
			return target[key];
		}
	}
}
