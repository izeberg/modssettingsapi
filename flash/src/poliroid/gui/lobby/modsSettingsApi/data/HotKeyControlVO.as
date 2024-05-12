package poliroid.gui.lobby.modsSettingsApi.data
{
	import net.wg.data.daapi.base.DAAPIDataClass;

	public class HotkeyControlVO extends DAAPIDataClass
	{
		public var linkage:String = "";
		public var varName:String = "";
		public var text:String = "";
		public var isEmpty:Boolean = false;
		public var isAccepting:Boolean = false;
		public var modifierCtrl:Boolean = false;
		public var modifierAlt:Boolean = false;
		public var modiferShift:Boolean = false;
		public var keyset:Array = [];

		public function HotkeyControlVO(data:Object)
		{
			super(data);
		}
	}
}
