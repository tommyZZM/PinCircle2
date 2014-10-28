package utils
{
	import flash.desktop.NativeApplication;
	
	import starling.core.Starling;
	import starling.text.TextField;
	import starling.utils.VAlign;

	public class Constants
	{
		public static var Width:int;//
		public static var Height:int;//
		
		public static var CenterX:int;//
		public static var CenterY:int;//
		
		public static var gravity:Number = 6.6;
		public static var worldScale:uint = 30; //30像素一米
		
		//获得版本号
		public static var xml : XML = NativeApplication.nativeApplication.applicationDescriptor;
		public static var ns : Namespace = xml.namespace();
		public static var VERSION : String = xml.ns::versionNumber;
		public static var LABER : String = xml.ns::versionLabel;
		
		public function Constants(){}
		
		public static  function info():TextField{
			var driverInfo:String = Starling.context.driverInfo;//底层显示驱动信息
			var infoText:TextField = new TextField(310, 64, "Game Version "+Constants.VERSION+" "+LABER+"\n"
				+"Rendermode: "+driverInfo, "Verdana", 10);
			//"Power By Starling\n"
			infoText.x = 5;
			infoText.y = (Constants.Height) -infoText.height;
			infoText.vAlign = VAlign.BOTTOM;
			//infoText.addEventListener(TouchEvent.TOUCH, onInfoTextTouched);//点击那里就会开关stats
			return infoText;
		}
	}
}