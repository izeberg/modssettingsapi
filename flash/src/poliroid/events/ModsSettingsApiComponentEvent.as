package poliroid.events
{
	import flash.events.*;
	
	public class ModsSettingsApiComponentEvent extends Event
	{
		
		public static const MOD_SETTINGS_CHANGED:String = "onModSettingsChanged";
		public var modLinkage:String = "";
		
		public function ModsSettingsApiComponentEvent(type:String, linkage:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.modLinkage = linkage;
		}
		
		public override function clone():Event
		{
			return new ModsSettingsApiComponentEvent(type, this.modLinkage, bubbles, cancelable);
		}
	
	}

}
