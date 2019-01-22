package poliroid.events
{
	import flash.events.*;
	
	public class ComponentEvent extends Event
	{
		
		public static const VALUE_CHANGED:String = "onValueChanged";
		
		public function ComponentEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
		
		public override function clone():Event
		{
			return new ComponentEvent(type, bubbles, cancelable);
		}
	
	}

}
