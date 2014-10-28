package starling.events
{
	public class ButtonEvent extends Event
	{
		/** Event type for a key that was released. */
		public static const BUTTON_UP:String = "buttonUp";
		
		/** Event type for a key that was pressed. */
		public static const BUTTON_DOWN:String = "buttonDown";
		
		public function ButtonEvent(type:String, bubbles:Boolean=false, data:Object=null)
		{
			super(type, bubbles, data);
		}
	}
}