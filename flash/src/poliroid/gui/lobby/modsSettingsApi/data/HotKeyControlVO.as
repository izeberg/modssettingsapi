package poliroid.gui.lobby.modsSettingsApi.data 
{
	import net.wg.data.daapi.base.DAAPIDataClass;
	
	public class HotKeyControlVO extends DAAPIDataClass
	{
		public var linkage:String = "";
		
		public var varName:String = "";
		
		public var value:String = "";
		
		public var isEmpty:Boolean = false;
		
		public var isAccepting:Boolean = false;
		
		public var modifierAlt:Boolean = false;
		
		public var modifierCtrl:Boolean = false;
		
		public var modiferShift:Boolean = false;

		public var keySet:Array = [];
		
		public function HotKeyControlVO(data:Object) 
		{
			super(data);
		}
	}
}