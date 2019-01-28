package poliroid.gui.lobby.modsSettingsApi.data 
{
	import net.wg.data.daapi.base.DAAPIDataClass;
	
	public class ModsSettingsStaticVO extends DAAPIDataClass
	{
		public var buttonOK:String = "";
		
		public var buttonCancel:String = "";
		
		public var buttonApply:String = "";

		public var buttonClose:String = "";

		public var windowTitle:String = "";

		public var stateTooltip:String = "";

		public var contextDefault:String = "";

		public var contextClean:String = "";
		
		public function ModsSettingsStaticVO(data:Object) 
		{
			super(data);
		}
	}
}