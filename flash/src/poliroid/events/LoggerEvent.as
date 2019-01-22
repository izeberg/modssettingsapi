package poliroid.events
{
	
	import flash.events.*;
	
	public class LoggerEvent extends Event
	{
		
		public static const LOG:String = "log";
		public var data:Array;
		
		public function LoggerEvent(type:String, data:Array, bubbles:Boolean = true, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.data = data;
		}
		
		public override function clone():Event
		{
			return new LoggerEvent(type, data, bubbles, cancelable);
		}
	
	}

}
