package
{
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	
	import starling.core.Starling;
	import starling.events.Event;
	import starling.textures.Texture;
	import starling.utils.AssetManager;
	import starling.utils.RectangleUtil;
	import starling.utils.ScaleMode;
	
	[SWF(width="320", height="480", frameRate="60", backgroundColor="#000000")]
	public class Main extends Sprite
	{
		[Embed(source="res/startupHD.jpg")]
		private static var BackgroundHD:Class;
		
		private var mStarling:Starling;
		
		public function Main()
		{
			super();
			
			// 支持 autoOrient
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			var stageWidth:int  = 320;
			var stageHeight:int = 480;
			var iOS:Boolean = Capabilities.manufacturer.indexOf("iOS") != -1;
			
			Starling.multitouchEnabled = false;  // 能否多点触控
			Starling.handleLostContext = !iOS;  // 在IOS系统下不需要handleLostContext，可以节省很多资源
			
			var viewPort:Rectangle = RectangleUtil.fit(
				new Rectangle(0, 0, stageWidth, stageHeight), 
				new Rectangle(0, 0, stage.fullScreenWidth, stage.fullScreenHeight), 
				ScaleMode.SHOW_ALL, iOS);
			
			var appDir:File = File.applicationDirectory;//File类型->包含应用程序已安装文件的文件夹。
			var assets:AssetManager = new AssetManager(2,false);//创建AssetManager
			
			assets.verbose = Capabilities.isDebugger;//是否输出加载过程中的信息? 
			
			assets.enqueue(
				appDir.resolvePath("res/")
				//,appDir.resolvePath("res/textures/obj")
			);
			
			var backgroundClass:Class = BackgroundHD
			var background:Bitmap = new backgroundClass();
			BackgroundHD = null; // 不再需要,释放内存
			
			background.x = viewPort.x;
			background.y = viewPort.y;
			background.width  = viewPort.width;
			background.height = viewPort.height;
			background.smoothing = true;
			addChild(background);
			
			mStarling = new Starling(Game, stage, viewPort);
			mStarling.stage.stageWidth  = stageWidth;  // <- same size on all devices!
			mStarling.stage.stageHeight = stageHeight; // <- same size on all devices!
			mStarling.simulateMultitouch  = false;
			mStarling.enableErrorChecking = false;
			
			mStarling.showStats = true;
			mStarling.showStatsAt("left", "top");
			
			mStarling.addEventListener(starling.events.Event.ROOT_CREATED, //[static] 事件类型：表示最顶层的显示对象已被创建。 
				function():void
			{
				removeChild(background);
				background = null;
				
				var game:Game = mStarling.root as Game;//构造中提供的根类的实例.'ROOT_CREATED'事件派发后可以使用. 
				var bgTexture:Texture = Texture.fromEmbeddedAsset(backgroundClass,
					false, false, 2); //载入背景资源
				game.start(bgTexture, assets);//game类的Start方法
				game.getstage(mStarling.stage);
				mStarling.start();
			});
			
			// When the game becomes inactive, we pause Starling; otherwise, the enter frame event
			// would report a very long 'passedTime' when the app is reactivated. 
			
			NativeApplication.nativeApplication.addEventListener(
				flash.events.Event.ACTIVATE, function (e:*):void { mStarling.start(); });
			
			NativeApplication.nativeApplication.addEventListener(
				flash.events.Event.DEACTIVATE, function (e:*):void { mStarling.stop(true); });
			
			
		}
	}
}