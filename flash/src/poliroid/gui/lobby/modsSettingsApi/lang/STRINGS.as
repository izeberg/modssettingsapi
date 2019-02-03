package poliroid.gui.lobby.modsSettingsApi.lang
{
	import poliroid.gui.lobby.modsSettingsApi.data.ModsSettingsStaticVO;

	public class STRINGS extends Object
	{
		public static var WINDOW_TITLE:String = "WINDOW_TITLE";
		public static var BUTTON_APPLY:String = "BUTTON_APPLY";
		public static var BUTTON_OK:String = "BUTTON_OK";
		public static var BUTTON_CANCEL:String = "BUTTON_CANCEL";
		public static var BUTTON_CLOSE:String = "BUTTON_CLOSE";
		public static var BUTTON_ENABLED_TOOLTIP:String = "BUTTON_ENABLED_TOOLTIP";
		public static var CONTEXT_DEFAULT:String = "CONTEXT_DEFAULT";
		public static var CONTEXT_CLEAN:String = "CONTEXT_CLEAN";
		
		public function STRINGS():void
		{
			super();
		}
		
		public static function updateStaticData(data:ModsSettingsStaticVO):void
		{
			WINDOW_TITLE = data.windowTitle;
			BUTTON_APPLY = data.buttonApply;
			BUTTON_OK = data.buttonOK;
			BUTTON_CANCEL = data.buttonCancel;
			BUTTON_CLOSE = data.buttonClose;
			BUTTON_ENABLED_TOOLTIP = data.stateTooltip;
			CONTEXT_DEFAULT = data.contextDefault;
			CONTEXT_CLEAN = data.contextClean;
		}
	}
}