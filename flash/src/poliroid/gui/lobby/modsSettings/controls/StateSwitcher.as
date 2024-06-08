package poliroid.gui.lobby.modsSettings.controls
{

	import flash.display.MovieClip;
	import net.wg.gui.components.controls.SoundButtonEx;
	import poliroid.gui.lobby.modsSettings.lang.STRINGS;

	public class StateSwitcher extends SoundButtonEx
	{

		private static const ICON_ENABLED:String = 'enabled';
		private static const ICON_DISABLED:String = 'disabled';

		public var icon:MovieClip;

		public function StateSwitcher()
		{
			super();
			preventAutosizing = true;
			constraintsDisabled = true;
			toggle = true;
			tooltip = STRINGS.BUTTON_ENABLED_TOOLTIP;
		}

		override public function set selected(value:Boolean):void
		{
			if (selected != value)
			{
				super.selected = value;
				icon.gotoAndStop(selected ? ICON_ENABLED : ICON_DISABLED);
			}
		}
	}
}
