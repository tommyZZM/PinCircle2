package
{
	import flash.system.System;
	import flash.utils.getDefinitionByName;
	
	import b2d.Box2DScene;
	
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.display.Stage;
	import starling.events.Event;
	import starling.textures.Texture;
	import starling.utils.AssetManager;
	
	import utils.Constants;
	import utils.ProgressBar;
	
	public class Game extends Sprite
	{
		private var mCurrentScene:Box2DScene;//当前场景~
		
		private var mLoadingProgress:ProgressBar;//ProgressBar 组件显示内容的加载进度。 
		private var mMainMenu:MainMenu;//MainMeun类
		private static var sAssets:AssetManager;//AssetManager这个类用于处理加载和访问各种素菜类型。
		
		private static var bAssets:AssetManager;//AssetManager这个类用于处理加载和访问各种素菜类型。
		
		public function Game()
		{
			super();
		}
		
		public function start(background:Texture, assets:AssetManager):void
		{
			sAssets = assets;
			
			addChild(new Image(background));
			
			mLoadingProgress = new ProgressBar(166, 20);
			mLoadingProgress.x = (background.width  - mLoadingProgress.width) / 2;
			mLoadingProgress.y = background.height * 0.7;
			addChild(mLoadingProgress);
			
			assets.loadQueue(function(ratio:Number):void
			{
				mLoadingProgress.ratio = ratio;//获取或设置一个值，指示加载操作中已完成的进度。
				
				// a progress bar should always show the 100% for a while,
				// so we show the main menu only after a short delay. 
				
				if (ratio == 1)
					Starling.juggler.delayCall(function():void
					{
						mLoadingProgress.removeFromParent(true);
						mLoadingProgress = null;
						showMainMenu();//加载完成~ 显示菜单
					}, 0.15);
			});
			
			addEventListener(Event.TRIGGERED, onButtonTriggered);//事件类型：按钮点击。 
		}
		
		private function showMainMenu():void
		{
			// now would be a good time for a clean-up 
			System.pauseForGCIfCollectionImminent(0);//如果垃圾回收器的临界值超过函数的临界参数，则建议回收器应完成增量回收循环。
			System.gc();//强制回收垃圾
			
			if (mMainMenu == null)
				mMainMenu = new MainMenu();
			
			addChild(mMainMenu);//菜单出来
		}
		
		public function getstage(stage:Stage):void
		{
			Constants.Width = stage.width;
			Constants.Height= stage.stageHeight;
			//trace("half="+(StageSize.Width>>1));
			Constants.CenterX = Constants.Width>>1;
			Constants.CenterY = Constants.Height>>1;
		}
		
		//全体按钮事件响应
		private function onButtonTriggered(event:Event):void
		{
			var button:Button = event.target as Button;
			
			if (button.name.toLocaleLowerCase() == "backbutton"){
				closeScene();
				Starling.current.showStats=true;
			}
			else
			{
				showScene(button.name);
				Starling.current.showStats=false;
			}
		}
		
		private function closeScene():void
		{
			mCurrentScene.removeFromParent(true);
			mCurrentScene = null;
			showMainMenu();
		}
		
		//显示场景按照字符串
		private function showScene(name:String):void
		{
			if (mCurrentScene) return;
			
			var sceneClass:Class = getDefinitionByName(name) as Class;
			mCurrentScene = new sceneClass() as Box2DScene;
			mMainMenu.removeFromParent();
			addChild(mCurrentScene);
		}
		
		public static function get assets():AssetManager { return sAssets; }
		
		public static function get bassets():AssetManager { return bAssets; }
		public static function set bassets(assets:AssetManager):void { bAssets = assets; }
		
	}
}