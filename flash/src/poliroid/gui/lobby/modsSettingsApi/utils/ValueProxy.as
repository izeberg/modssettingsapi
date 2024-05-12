package poliroid.gui.lobby.modsSettingsApi.utils
{
	public class ValueProxy
	{
		private var _target:*;
		private var _key:*;

		public function ValueProxy(target:*, key:*)
		{
			if (!target)
				throw new Error("[ModsSettings API] Target is missing!");
			if (!key)
				throw new Error("[ModsSettings API] Key is missing!");

			_target = target;
			_key = key;
		}

		public function get value():*
		{
			return _target[_key];
		}
	}
}
