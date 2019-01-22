package poliroid.utils
{
	
	public class ValueProxy
	{
		
		public var target:*;
		public var key:*;
		
		public function ValueProxy(target:* = null, key:* = null)
		{
			this.target = target;
			this.key = key;
		}
		
		public function get value():*
		{
			return key != null ? target[key] : target;
		}
	}

}
