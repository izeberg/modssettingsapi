package poliroid.gui.lobby.modsSettings.shared
{
	public class Utilities
	{
		public function Utilities()
		{
			super();
		}

		public static function getFormattedSliderValue(format:String, value:String):String
		{
			return format ? format.split(Constants.SLIDER_VALUE_KEY).join(value) : value;
		}
	}
}
