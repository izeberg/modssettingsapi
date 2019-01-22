package poliroid.utils
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.utils.getQualifiedClassName;
	import flash.text.TextField;
	
	public class Utils
	{
		
		public static var _stageRef:Stage = null;
		private static var debugPanel:TextField = null;
		private static var debuginfo:Array = new Array();
		
		public function Utils()
		{
			super();
		}
		
		public static function recursiveFindDOC(dOC:DisplayObjectContainer, className:String) : DisplayObjectContainer 
		{
			var child:DisplayObject = null;
			var childOC:DisplayObjectContainer = null;
			var i:int = 0;
			var result:DisplayObjectContainer = null;
			while (i < dOC.numChildren) {
				child = dOC.getChildAt(i);
				if ((child is DisplayObject) && (getQualifiedClassName(child) == className)) result = child as DisplayObjectContainer;
				if (result != null) return result;
				childOC = child as DisplayObjectContainer;
				if ((childOC) && (childOC.numChildren > 0)) result = Utils.recursiveFindDOC(childOC, className);
				i++;
			}
			return result;
		}
		
		public static function recursivePrintDOC(dOC:DisplayObjectContainer = null, deph:Number = 1, logData:String = "") : String 
		{	
			var child:DisplayObject = null;
			var childOC:DisplayObjectContainer = null;
			var i:int = 0;
			var logstr:String = "";
			for (var _l:Number = 0; _l<deph; _l++) logstr += "|  ";
			while (i < dOC.numChildren) {
				child = dOC.getChildAt(i);
				logData += logstr + " " + getQualifiedClassName(child) + " " + child.name + "\n"
				childOC = child as DisplayObjectContainer;
				if ((childOC) && (childOC.numChildren > 0)) logData = Utils.recursivePrintDOC(childOC, deph + 1, logData);
				i++;
			}
			return logData;
		}
		
		public static function _DEBUG(... args:Array) : void
		{
			var dbg:Array = new Array();
			
			var t:Array = new Array();
			for (var i:uint = 0; i < args.length; i++) 
			{
				t.push(String(args[i]))
			}
			debuginfo.unshift(t.join(", "));
			debuginfo = debuginfo.slice(0, Math.min(50, debuginfo.length));

			if (!debugPanel && _stageRef != null) {
				debugPanel = new TextField();
				_stageRef.addChild(debugPanel);
				debugPanel.background = true;
				debugPanel.backgroundColor = 0xFFFFFF;
				debugPanel.border = true;
				debugPanel.multiline = true;
				debugPanel.wordWrap = true;
				debugPanel.width = 400;
				debugPanel.height = 500;
				debugPanel.x = 300;
				debugPanel.y = 300;
			}
			
			debugPanel.text = debuginfo.join("\n");
			
		}
		
	}
}
