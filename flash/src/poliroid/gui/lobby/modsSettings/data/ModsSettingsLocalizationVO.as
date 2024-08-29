package poliroid.gui.lobby.modsSettings.data
{
	import net.wg.data.daapi.base.DAAPIDataClass;

	public class ModsSettingsLocalizationVO extends DAAPIDataClass
	{
		public var windowTitle:String = "";
		public var stateTooltip:String = "";
		public var popupColor:String = "";
		public var buttonOK:String = "";
		public var buttonCancel:String = "";
		public var buttonApply:String = "";
		public var buttonClose:String = "";

		public function ModsSettingsLocalizationVO(data:Object)
		{
			super(data);
		}
	}
}
