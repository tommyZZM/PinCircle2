package gameobj
{
	import starling.events.Event;
	
	public class CustomEvent extends Event
	{
		public static const BrickLOCKED:String = "BrickLocked";
		public static const BrickDESTROY:String = "BrickDestroy";
		
		public function CustomEvent(type:String, bubbles:Boolean=false, data:Object=null)
		{
			super(type, bubbles, data);
		}
	}
}