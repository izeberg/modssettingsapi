package poliroid.utils
{
	
	import poliroid.events.LoggerEvent;
	import poliroid.events.*;
	import flash.events.*;
	
	public class Logger
	{
		
		public static const globalDispatcher:EventDispatcher = new EventDispatcher();
		
		public function Logger()
		{
		}
		
		public static function Error(... args):void
		{
			args.unshift("ERROR");
			__doLog.apply(null, args);
		}
		
		public static function Debug(... args):void
		{
			args.unshift("DEBUG");
			__doLog.apply(null, args);
		}
		
		private static function __doLog():void
		{
			var results:Array = [];
			while (arguments.length)
			{
				results.push(String(arguments.shift()));
			}
			globalDispatcher.dispatchEvent(new LoggerEvent(LoggerEvent.LOG, results));
		}
	
		public static function ErrorLog(funcName:String, errorMsg:String):void
		{
			Logger.Error(funcName + " : " + errorMsg);
			//DebugUtils.LOG_ERROR(ERROR_PREFIX + funcName + " : " + errorMsg);
		}
		
		public static function DebugLog(... args):void
		{
			if (Constants.IS_DEVELOPMENT)
			{
				Logger.Debug(args.toString());
					//DebugUtils.LOG_DEBUG(DEBUG_PREFIX + args);
			}
		}
		
	}

}
