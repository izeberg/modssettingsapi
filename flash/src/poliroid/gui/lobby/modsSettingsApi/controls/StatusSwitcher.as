package poliroid.gui.lobby.modsSettingsApi.controls
{
	import flash.display.MovieClip;
	import net.wg.gui.components.controls.SoundButtonEx;
	import poliroid.gui.lobby.modsSettingsApi.lang.STRINGS;

	public class StatusSwitcher extends SoundButtonEx
	{
		private static const ICON_ENABLED:String = 'enabled';
		private static const ICON_DISABLED:String = 'disabled';

		public var icon:MovieClip;

		private var _enabled:Boolean = false;

		public function StatusSwitcher()
		{
			super();

			tooltip = STRINGS.BUTTON_ENABLED_TOOLTIP;
		}

		public function set isEnabled(value:Boolean):void
		{
			if (value == _enabled)
				return;

			_enabled = value;
			icon.gotoAndStop(_enabled ? ICON_ENABLED : ICON_DISABLED);
		}

		public function get isEnabled():Boolean
		{
			return _enabled;
		}
	}
}
