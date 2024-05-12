package poliroid.gui.lobby.modsSettingsApi.utils
{
	public class ValueProxy
	{
		public var target:*;
		public var key:*;

		public function ValueProxy(target:*, key:*)
		{
			if (!target)
				throw new Error("[ModsSettings API] Wrong target");
			if (!key)
				throw new Error("[ModsSettings API] Wrong key");

			this.target = target;
			this.key = key;
		}

		public function get value():*
		{
			return target[key];
		}
	}
}
