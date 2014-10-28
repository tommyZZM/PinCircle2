package
{
	import flash.events.TimerEvent;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	
	import b2d.Box2DObject;
	import b2d.Box2DScene;
	import b2d.events.ContactEvent;
	
	import gameobj.Bricks;
	import gameobj.CustomEvent;
	
	import starling.display.Button;
	import starling.display.ButtonEx;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.ButtonEvent;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	import utils.Constants;
	import utils.CurrentFont;
	import utils.Font;
	
	public class InGame extends Box2DScene
	{
		private var mBackButton:Button;
		
		private var fontScoreValue:Font;
		
		//游戏里的属性
		private var vector:b2Vec2 = new b2Vec2();
		public static var GameScore:int = 0;
		private var ScoreText:TextField;
		
		private var isStart:Boolean = false;
		private var isRun:Boolean  = false;
		private var isFail:Boolean  = false;
		
		//游戏里的物件
		private var bezel:Box2DObject
		private var circle:Box2DObject
		
		private var brickGroupList:Array = [];
		private var firstBirck:Bricks;
		
		private var deadline:Quad= new Quad(Constants.Width,1,0xffa200);
		private var darkscreen:Quad= new Quad(Constants.Width,Constants.Height,0x232323);
		
		//游戏阶数
		private var MAXROW:int = 3;
		private var levelCount:int = 1;
		private var level:int = 1;
		private var moveTimer:Timer;
		
		private var bspeed:Number = 6.6;
		private var speed:Number = 4.2;
		
		//debug
		private var greenPoint:Quad = new Quad(6,6,0x61bb00);
		private var redPoint:Quad = new Quad(6,6,0xbb1a00);
		
		public function InGame()
		{
			super();
			this.addEventListener(Event.ADDED_TO_STAGE,onAdderToStage);
			this.addEventListener(Event.REMOVED_FROM_STAGE,onRemoveFromStage);
		}
		
		protected override function onTextureLoaded():void
		{
			addChild(new Image(sceneAssets.getTexture("background_p1")));
			initializeGame();
			createButton();
			GameReady();
			this.addEventListener(EnterFrameEvent.ENTER_FRAME,onEnterFrame);
		}
		
		protected override function onFrameLoop():void
		{
			if (isStart) 
			{
				updateGame();
			}
		}
		
		protected override function onRemoveFromStage(event:Event):void
		{
			destroyGame();
		}
		
		private function GameReady():void
		{
			isFail = false;
			darkscreen.x=0,y=0,alpha=0.86;
			addChild(darkscreen);
			newButton("anniuBig_go","GoButton",Constants.CenterX,Constants.CenterY+23);
		}
		
		private function GameFail():void
		{
			isFail = true;
			worldRun = false;
			darkscreen.x=0,y=0,alpha=0.86;
			addChild(darkscreen);
			darkscreen.visible = true;
			newButton("anniuBig_restar","failButton",Constants.CenterX,Constants.CenterY+23);
		}
		
		private function initializeGame():void{
			GameScore = 0;
			createScore();
			
			MAXROW = 3;
			levelCount = 1;
			level =1;
			//TODO:初始化游戏
			initRestrictedArea();
			createLine();
			//创建物体
			bezel  = new Box2DObject(Constants.CenterX,Constants.Height-80);
			bezel.density = 10;
			bezel.friction = 1.1;
			bezel.restitution = 0.1;
			addChild(bezel.New("dynamic","bezel","bezel"));
			world.createPrismaticJointLite(bezel.body,new b2Vec2(1,0));
			
			
			circle = new Box2DObject(bezel.x,bezel.y-26,"circle",16,16);
			circle.density = 0.6;
			circle.friction = 0.6;
			circle.restitution = 0.1;
			addChild(circle.New("dynamic","circle","circle"));
			//circle.body.SetFixedRotation(true);
			
			firstBirck = new Bricks(this);
			firstBirck.addEventListener(CustomEvent.BrickLOCKED,OnBrickLock);
			brickGroupList.push(firstBirck);
			
			isStart = true;
			
			worldRun = true;
			
		}
		
		private function runGame():void{
			//设置更新频率
			moveTimer=new Timer(2000);
			moveTimer.start();
			moveTimer.addEventListener(TimerEvent.TIMER,UnLockBricks);
			
			var angle:Number = Math.PI *1.875 +Math.random() * Math.PI *0.25;
			//速度的大小统一都是speed
			var velocity:b2Vec2 = new b2Vec2(speed * Math.sin(angle), speed * Math.cos(angle));
			//设置刚体的速度
			circle.body.SetLinearVelocity(velocity);
			
			b2dworld.SetContactListener(new ContactEvent(b2dworld));
			
			isRun = true;
			isFail= false;
			
			this.addEventListener(KeyboardEvent.KEY_DOWN,OnKeyDown);
			this.addEventListener(KeyboardEvent.KEY_UP,OnKeyUp);
		}
		
		private function updateGame():void{
			//更新游戏
			//bezel.body.ApplyImpulse(vector, bezel.body.GetWorldCenter());//施加速度之后立刻唤醒
			bezel.createVelocity(vector);
			checkCircel();//胜负判定
			if (isRun) 
			{
				circle.makeCrazy(speed,Constants.gravity);
				
			}
			ScoreText.text = GameScore.toString();
			//test.moveTheBrick();
			UpdateBricks();
			
			//避免一个偶见的BUG
			//trace(b2dworld.GetBodyCount());
			var body:b2Body = b2dworld.GetBodyList()
			for (var i:int =0;i<b2dworld.GetBodyCount();i++) 
			{
				if (body.GetUserData()!=null) 
				{
					//trace("getuserdata"+body.GetUserData().name);
					if(body.GetUserData().name =="brickR"||body.GetUserData().name =="brickO"||body.GetUserData().name =="brickB"){
						if (body.GetPosition().y*Constants.worldScale>bezel.y+6||
							body.GetLinearVelocity().y>2.33||
							body.GetUserData().visible==false) 
						{
						body.GetUserData().removeFromParent(true);
						b2dworld.DestroyBody(body);
						trace("destory");
						}
					}
				}
				body = body.GetNext();
			}
		}
		
		private function destroyGame():void{
			worldRun = false;
			ScoreText.removeFromParent(true);
			moveTimer.removeEventListener(TimerEvent.TIMER,UnLockBricks);
			moveTimer.stop();
			for each (var group:Bricks in brickGroupList) 
			{
				group.destroyTheBrick();
			}
			brickGroupList = [];
			for (var i:int = 0; i < b2dworld.GetBodyCount(); i++) 
			{
				var body:b2Body = b2dworld.GetBodyList()
				b2dworld.GetBodyList().GetUserData().removeFromParent(true);
				b2dworld.DestroyBody(b2dworld.GetBodyList());
				body.GetNext();
			}
			this.removeEventListener(KeyboardEvent.KEY_DOWN,OnKeyDown);
			this.removeEventListener(KeyboardEvent.KEY_UP,OnKeyUp);
		}
		
		////////////////////////////////////////////
		
		private function UnLockBricks(event:TimerEvent):void{
			if (circle.body.GetPosition().y*Constants.worldScale > Constants.Height*0.33) 
			{
				//trace("ok");
				//debugGreen(circle.body.GetPosition().x*Constants.worldScale,circle.body.GetPosition().y*Constants.worldScale);
				if (levelCount<MAXROW) 
				{
					for each (var group:Bricks in brickGroupList) 
					{
						group.unlockTheBrick();
					}
					//trace("unLock");
				}
				else
					trace("full!");
			}
			else
			{
				var quickupdate:Timer = new Timer(500,1);
				quickupdate.addEventListener(TimerEvent.TIMER,UnLockBricks);
				quickupdate.start();
				//trace("not!ok"+" circle="+circle.body.GetPosition().x*Constants.worldScale+" h="+Constants.Height*0.25);
				//debugRed(circle.body.GetPosition().x*Constants.worldScale,circle.body.GetPosition().y*Constants.worldScale);
			}
		}
		
		private function UpdateBricks():void{
			var count:int = 0;
			if (levelCount==0) 
			{
				if (circle.body.GetPosition().y*Constants.worldScale > Constants.Height*0.33) 
				{
					brickGroupList = [];
					CreateLevel();
					brickGroupList[0].addEventListener(CustomEvent.BrickLOCKED,OnBrickLock);
					//debugGreen(circle.body.GetPosition().x*Constants.worldScale,circle.body.GetPosition().y*Constants.worldScale);
				}
				else{
					//debugRed(circle.body.GetPosition().x*Constants.worldScale,circle.body.GetPosition().y*Constants.worldScale);
				}
			}
			for each (var group:Bricks in brickGroupList) 
			{
				if (brickGroupList.length>0) 
				{
					//trace("brickGroupList.length"+brickGroupList.length);
					group.updateTheBrick();
					group.updateTheList();
					group.moveTheBrick();
					if (group.IsAlive==false) 
					{
						brickGroupList.splice(count,1);
						if (count==0) 
						{
							if (brickGroupList[0]!=undefined) 
							{
								//trace("new head"+"lenth"+brickGroupList.length);
								brickGroupList[0].addEventListener(CustomEvent.BrickLOCKED,OnBrickLock);
							}
							levelCount=brickGroupList.length;
							//trace("count"+count);
							//trace("levelCount"+levelCount);
						}
					}
					else
						count++;
				}
			}
		}
		
		private function OnBrickLock(event:CustomEvent):void
		{
			//trace("Locked! Begin create");
			CreateLevel();
			//
			for each (var group:Bricks in brickGroupList) 
			{
				group.updateTheList();
			}
		}
		
		private function CreateLevel():void{
			brickGroupList.push(new Bricks(this));
			levelCount++;
			level++
			//trace("try create "+"Level:"+level);
			//trace("try create "+"LevelCount:"+levelCount);
			if (level==3) 
			{
				nextStage();
				//trace("next");
			}
			function nextStage():void
			{
				moveTimer.removeEventListener(TimerEvent.TIMER,UnLockBricks);
				moveTimer = new Timer(9600);
				moveTimer.addEventListener(TimerEvent.TIMER,UnLockBricks);
				moveTimer.start();
				MAXROW = 6;
			}
		}
		
		////////////////////////////////////////////
		
		private function checkCircel():void
		{
			if(circle.body.GetPosition().y*30>deadline.y){
				//trace("lost");
				GameFail();
			}
		}
		
		/////////////////////////////////////////
		
		private function createButton():void
		{
			//显示返回按钮~
			newButton("anniu_back","backButton",40,60);//Button
			newButton("anniu_restart","restartButton",Constants.Width-40,60);//ButtonEx
			newButton("anniu_left","leftButton",40,Constants.Height-10);//ButtonEx
			newButton("anniu_right","rightButton",Constants.Width-40,Constants.Height-10);//ButtonEx
			this.addEventListener(ButtonEvent.BUTTON_DOWN,onButtonDown);
			this.addEventListener(ButtonEvent.BUTTON_UP,onButtonUp);
		}
		
		private function onButtonDown(event:Event):void
		{
			var button:ButtonEx = event.target as ButtonEx;
			button.name=="leftButton"?(vector.x = -bspeed):{};
			button.name=="rightButton"?(vector.x = bspeed):{};
		}
		
		private function onButtonUp(event:Event):void
		{
			var button:ButtonEx = event.target as ButtonEx;
			vector.SetZero();
			
			if (button.name=="GoButton") 
			{
				button.removeFromParent(true);
				darkscreen.visible = false;
				runGame();
			}
			
			if (button.name=="failButton") 
			{
				if (isFail) 
				{
					button.removeFromParent(true);
					darkscreen.visible = false;
					destroyGame();
					initializeGame();
					runGame();
				}
				
			}
			
			if (button.name=="restartButton") 
			{
				if (!isFail) 
				{
					destroyGame();
					initializeGame();
					runGame();
				}
			}
		}
		
		private function createScore():void
		{
			fontScoreValue = CurrentFont.getFont("ScoreValue");
			
			// Score
			ScoreText = new TextField(150, 66, GameScore.toString(), fontScoreValue.fontName, fontScoreValue.fontSize, 0xffffff);
			ScoreText.hAlign = HAlign.CENTER;
			ScoreText.vAlign = VAlign.CENTER;
			
			ScoreText.x = Constants.CenterX-(ScoreText.width>>1);
			ScoreText.y = 0;
			this.addChild(ScoreText);
		}
		
		private function createLine():void{
			deadline.pivotX = deadline.width>>1;
			deadline.x = Constants.CenterX;
			deadline.y = Constants.Height-80;
			addChild(deadline);
		}
		
		////
		private function OnKeyDown(event:KeyboardEvent):void
		{
			switch(event.keyCode)
			{
				case Keyboard.LEFT:
				{
					vector.x = -15;
					break;
				}
				case Keyboard.RIGHT:
				{
					vector.x = 15;
					break;
				}
				default:
				{
					break;
				}
			}
		}
		
		private function OnKeyUp(event:KeyboardEvent):void
		{
			vector.SetZero();
		}
		
		//debug专用方法，在屏幕指定位置绘制红点和绿点
		private function debugGreen(x:int,y:int):void
		{
			greenPoint.x = x;
			greenPoint.y = y;
			addChild(greenPoint);
		}
		
		private function debugRed(x:int,y:int):void
		{
			redPoint.x = x;
			redPoint.y = y;
			addChild(redPoint);
		}
		
	}
}