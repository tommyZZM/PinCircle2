package gameobj
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2WeldJoint;
	
	import b2d.Box2DObject;
	import b2d.Box2DScene;
	
	import starling.events.EventDispatcher;
	
	import utils.Constants;
	
	[Event(name="BrickLocked", type="gameobj.CustomEvent")]

	public class Bricks extends EventDispatcher
	{
		private var m_sce:Box2DScene;
		
		private var brickList:Array = [];
		private var brickJointList:Array = [];
		
		private var brickPos_last:Array = [];
		
		private var brickIsLock:Boolean = false;
		private var brickIsAlive:Boolean;
		
		private var BrickTotal:int = 7;
		private var red:int = 1;
		private var ora:int = 2;
		private var blu:int = 3;
		
		private var red_rate:Number;
		private var orange_rate:Number;
		private var blue_rate:Number;
		
		private var Dice:Number
		
		public function Bricks(scene:Box2DScene)
		{
			m_sce = scene;
			brickIsAlive = true;
			
			
			//创建一行砖
			for (var i:int = 0; i < BrickTotal; i++) {
				var colour:int;
				Dice = Math.random();//掷骰子
				Dice<0.25?
					Dice<0.05?colour=blu:colour=ora:
					colour=red;
				if (i!=0) {
					i%2==0?
						createBrick(Constants.CenterX-(43*(i>>1)),90,colour):
						createBrick(Constants.CenterX+(43*((i+1)>>1)),90,colour);
				}
				else
					createBrick(Constants.CenterX,90,colour);
			}
			lockTheBrick();
		}
		
		public function unlockTheBrick():void
		{
			if (brickIsLock==true) 
			{
				for each (var joint:b2WeldJoint in brickJointList) 
				{
					Box2DScene.sceneWorld.DestroyJoint(joint);
				}
				brickJointList = [];
				brickPos_last = [];
				for each (var brick:Box2DObject in brickList) 
				{
					brick.createForce(new b2Vec2(0, -Constants.gravity*brick.body.GetMass()),brick.body.GetWorldCenter());
					brickPos_last.push(brick.body.GetPosition().y);
				}
				brickIsLock=false;
			}
		}
		
		public function updateTheBrick():void
		{
			var count:int = 0;
			for each (var brick:Box2DObject in brickList) 
			{
				if (brick.body.GetUserData().visible == false) 
				{
					Box2DScene.b2dworld.DestroyBody(brick.body);
					brick.body.GetUserData().removeFromParent(true);
					brickList.splice(count,1);
					//Trace("brickList"+count);
					//trace("destory "+count);
				}
				else
					count++;
			}
		}
		
		public function updateTheList():void
		{
			if (brickList.length == 0) 
			{
				//trace("kill a  box");
				//dispatchEvent(new CustomEvent("BrickDestroy",true));
				brickIsAlive = false;
			}
		}
		
		public function get IsAlive():Boolean{return brickIsAlive;}
		
		public function moveTheBrick():void{
			var count:int = 0;
			if (brickIsLock==false) 
			{
				for each (var brick:Box2DObject in brickList) 
				{
					//trace("moveTheBrick"+count);
					if (brick.body.GetPosition().y<=brickPos_last[count]+1.5) 
					{
						brick.createForce(new b2Vec2(0, -(Constants.gravity*0.99)*brick.body.GetMass()),brick.body.GetWorldCenter());
						brick.setLinearVelocity(2.3);
					}
					else
						lockTheBrick();
					count++;
				}
			}
		}
		
		public function lockTheBrick():void
		{
			if (brickIsLock==false) 
			{
				var count:int = 0;
				for each (var brick:Box2DObject in brickList) 
				{
					brickJointList.push(m_sce.world.createWeldJointLite(Box2DScene.sceneWorld.GetGroundBody(),brick.body,brick.body.GetPosition()));//new b2Vec2(0,0)
					count++;
				}
				brickIsLock=true;
				dispatchEvent(new CustomEvent("BrickLocked",true));
			}
		}
		
		public function destroyTheBrick():void
		{
			var count:int = 0;
			for each (var brick:Box2DObject in brickList) 
			{
				brick.body.GetUserData().removeFromParent(true);
				Box2DScene.b2dworld.DestroyBody(brick.body);
			}
			brickList = null;
		}
		
		private function createBrick(x:int,y:int,type:Number):void{
			var brick:Box2DObject=new Box2DObject(x,y,"box",36,36);
			brick.density = 10;
			brick.rotation = false;
			brickList.push(brick);
			
			//type==RED?m_sce.addChild(brick.New("static","brick_red")):null;
			switch(type){
				default:
				case red:{
					m_sce.addChild(brick.New("dynamic","brick_red","brickR"));
					break;
				}	
				case ora:{
					m_sce.addChild(brick.New("dynamic","brick_orange","brickO"));
					break;
				}	
				case blu:{
					m_sce.addChild(brick.New("dynamic","brick_blue","brickB"));
					break;
				}
			}
			
		}
	}
}