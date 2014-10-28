package b2d
{
	import flash.filesystem.File;
	import flash.system.Capabilities;
	
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2World;
	import Box2D.Dynamics.Joints.b2MouseJoint;
	import Box2D.Dynamics.Joints.b2MouseJointDef;
	
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.ButtonEx;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.utils.AssetManager;
	
	import utils.Constants;
	import utils.ProgressBar;
	
	public class Box2DScene extends Sprite
	{
		public var world:Box2DWorld;
		public static var b2dworld:b2World;
		
		public var worldRun:Boolean = true;
		/**
		 * 
		 */
		
		private var jointDef:b2MouseJointDef;
		private var joint:b2MouseJoint;
		
		//obj
		private var m_worldtop:Box2DObject
		private var m_worldleft:Box2DObject
		private var m_worldright:Box2DObject
		private var m_worldbottom:Box2DObject
		
		public function Box2DScene()
		{
			super();
		}
		
		public function createB2dWorld():void
		{
			world = new Box2DWorld();
			b2dworld = Box2DWorld.gworld;
		}
		
		protected function onAdderToStage(event:Event):void
		{
			LoadAssest();
		}
		
		protected function onRemoveFromStage(event:Event):void
		{
			//mAssest=null;
		}
		
		protected final function onEnterFrame(event:Event):void
		{
			if (worldRun) 
			{
				world.updateWorld();
				onFrameLoop();
				world.updateBody();
			}
		}
		
		protected function onFrameLoop():void{}
		
		protected function onTextureLoaded():void{}
		
		protected final function initRestrictedArea(top:Boolean=true,left:Boolean=true,right:Boolean=true,bottom:Boolean=true):void
		{
			m_worldtop = new Box2DObject(Constants.CenterX,0,"box",Constants.Width,1);
			m_worldleft= new Box2DObject(0,Constants.CenterY,"box",1,Constants.Height);
			m_worldright= new Box2DObject(Constants.Width,Constants.CenterY,"box",1,Constants.Height);
			m_worldbottom = new Box2DObject(Constants.CenterX,Constants.Height-1,"box",Constants.Width,1);
			
			m_worldtop.restitution =  m_worldleft.restitution = m_worldright.restitution = m_worldbottom.restitution = 0.2;
			m_worldtop.friction =  m_worldleft.friction = m_worldright.friction = m_worldbottom.friction = 1.1;
			//TODO:创建限制区域
			top?addChild(m_worldtop.New("static")):null;
			left?addChild(m_worldleft.New("static")):null;
			right?addChild(m_worldright.New("static")):null;
			bottom?addChild(m_worldbottom.New("static")):null;
		}
		
		public final function get worldTop():b2Body{return m_worldtop.body}
		public final function get worldBottom():b2Body{return m_worldbottom.body}
		public final function get worldLeft():b2Body{return m_worldleft.body}
		public final function get worldRight():b2Body{return m_worldright.body}
		
		protected final function newButton(type:String,id:String,x:int,y:int,inname:String="",assest = undefined):void
		{
			var button:DisplayObject;
			if (assest == undefined) 
			{
				id.toLocaleLowerCase() == "backbutton"?
					button = new Button(Game.bassets.getTexture(type), inname):
					button = new ButtonEx(Game.bassets.getTexture(type), inname);
			}
			else
			{
				id.toLocaleLowerCase() == "backbutton"?
					button = new Button(assest.getTexture(type), inname):
					button = new ButtonEx(assest.getTexture(type), inname);
			}
			button.x = x-(button.width>>1);
			button.y = y-button.height;
			//trace(StageSize.Height);
			button.name = id;
			addChild(button);
		}
		
		public static function get sceneAssets():AssetManager { return Game.bassets; }
		public static function get sceneWorld():b2World { return b2dworld; }
		
		private function LoadAssest():void
		{
			var appDir:File = File.applicationDirectory;//File类型
			loadTexture(appDir.resolvePath("res_game/textures/obj/"));
		}
		
		private function loadTexture(... rawAssets):void
		{
			
			if (Game.bassets==null) 
			{
				Game.bassets = new AssetManager(2,false);//创建AssetManager
				Game.bassets.verbose = Capabilities.isDebugger;//是否输出加载过程中的信息? 
				var appDir:File = File.applicationDirectory;//File类型
				
				Game.bassets.enqueue(rawAssets);//读取路径资源appDir.resolvePath("Tube/Texture")
				
				var mLoadingProgress:ProgressBar;//ProgressBar 组件显示内容的加载进度。 
				mLoadingProgress = new ProgressBar(166, 20);
				mLoadingProgress.x = Constants.CenterX -(mLoadingProgress.width>>1);
				mLoadingProgress.y = Constants.Height * 0.7;
				addChild(mLoadingProgress);
				
				Game.bassets.loadQueue(function(ratio:Number):void
				{
					mLoadingProgress.ratio = ratio;//获取或设置一个值，指示加载操作中已完成的进度。
					
					if (ratio == 1)
						Starling.juggler.delayCall(function():void
						{
							mLoadingProgress.removeFromParent(true);
							mLoadingProgress = null;
							createB2dWorld();
							onTextureLoaded();
						}, 0.15);
				});
			}
			else
			{
				createB2dWorld();
				onTextureLoaded();
			}
		}
	}
}