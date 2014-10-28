package b2d
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	
	import starling.display.Image;
	import starling.display.Quad;
	
	import utils.Constants;

	public class Box2DObject
	{
		private var m_x:Number;
		private var m_y:Number;
		
		private var m_width:Number;
		private var m_height:Number;
		
		private var m_shape:String;
		
		public var density:Number=0.6;//密度
		public var friction:Number=0.5;//摩擦
		public var restitution:Number=0.5;//弹性系数
		
		public var rotation:Boolean=true;//弹性系数
		
		public var  body:b2Body;
		private var m_obj:Quad;
		
		private var create:Boolean = false;
		
		private static var ObjectData:XML;
		
		public function Box2DObject(x:int,y:int,shape:String="box",width:int=0,height=0):void
		{
			m_x=x;
			m_y=y;
			m_width=width;
			m_height=height;
			m_shape=shape;
			if (create) 
			{
				create =!create;
			}
		}
		
		public function New(status:String="dynamic",texture:String=null,name:String="default"):Quad
		{
			if (!create) 
			{
				create =!create;
				if (texture!=null) 
				{
					m_obj = drawBody(texture,name,m_x,m_y,m_width,m_height)
					box2dBody(m_obj,name,status,m_shape);
				}
				else
				{
					m_obj = drawAidBody();
					box2dBody(m_obj,"aidobj",status);
				}
			}
			else
			{
				trace("不能重复创建物体");
				m_obj = new Quad(10,10);
				m_obj.visible = false
			}
			return m_obj;
		}
		
		public function Destory():void{
			
		}
		
		public function createVelocity(vector:b2Vec2):void{
			body.SetAwake(true);//必须唤醒物体再设置速度，才会进行模拟运算
			body.SetLinearVelocity(vector);
		}
		
		public function createForce(vector:b2Vec2,point:b2Vec2):void{
			body.ApplyForce(vector,body.GetWorldCenter());
		}
		
		public function makeCrazy(speed:Number,gravity:Number = 9.8):void{
			body.ApplyForce(new b2Vec2(0, -gravity*body.GetMass()),body.GetWorldCenter());
			
			var velocity:b2Vec2 = body.GetLinearVelocity();
			velocity.Normalize();
			velocity.Multiply(speed);
		}
		
		public function setLinearVelocity(speed:Number):void{
			var velocity:b2Vec2 = body.GetLinearVelocity();
			velocity.Normalize();
			velocity.Multiply(speed);
		}
		
		private function box2dBody(object:Quad,
								     name:String,
								     status:String="dynamic",//类型
									 shape:String="box"//类型
		):Quad
		{
			var bodyDef:b2BodyDef = new b2BodyDef;
			bodyDef.position.Set(object.x/Constants.worldScale, object.y/Constants.worldScale);
			bodyDef.userData = object;
			bodyDef.userData.name = name;
			//trace(bodyDef.userData.name);
			switch(status.toLocaleLowerCase())
			{
				default:
				case "dynamic":
				{
					bodyDef.type = b2Body.b2_dynamicBody;
					break;
				}
					
				case "static":
				{
					bodyDef.type = b2Body.b2_staticBody;
					break;
				}
			}
			
			var fixtureDef:b2FixtureDef;
			fixtureDef = new b2FixtureDef;
			switch(shape.toLocaleLowerCase())
			{
				default:
				case "box":
				{
					var nbox:b2PolygonShape = new b2PolygonShape;
					nbox.SetAsBox(object.width / Constants.worldScale / 2, object.height / Constants.worldScale / 2);
					fixtureDef.shape = nbox;
					fixtureDef.density = density;
					fixtureDef.friction = friction;
					fixtureDef.restitution = restitution;
					break;
				}
					
				case "circle":
				{
					var circleShape:b2CircleShape = new b2CircleShape();
					//trace("Circle="+object.width);
					circleShape.SetRadius((object.width>>1)/Constants.worldScale);
					fixtureDef.shape = circleShape;
					fixtureDef.density = density;
					fixtureDef.friction = friction;
					fixtureDef.restitution = restitution;
					break;
				}
			}
			body = Box2DScene.sceneWorld.CreateBody(bodyDef);
			body.CreateFixture(fixtureDef);
			//body.SetFixedRotation(!rotation);
			return object;
		}
		
		private function drawBody(texture:String,name:String,x:int=0,y:int=0,width:Number=0,height:Number=0):Quad
		{
			//TODO:创建物体
			var bodylook:Image;
			bodylook = new Image(Box2DScene.sceneAssets.getTexture(texture));
			//trace(bodylook.width);
			bodylook.pivotX=bodylook.width>>1;
			bodylook.pivotY=bodylook.height>>1;
			if (width!=0 || height!=0) 
			{
				bodylook.width=width;
				bodylook.height=height;
			}
			
			bodylook.x=(x==0?Constants.CenterX:x);
			bodylook.y=(y==0?Constants.CenterY:y);
			bodylook.smoothing = "trilinear";
			return bodylook;
		}
		
		private function drawAidBody(alpha:Number = 0.8,name:String = "default"):Quad
		{
			var aidlook:Quad = new Quad(m_width,m_height,0xeeeeee);
			aidlook.alpha = alpha;
			aidlook.pivotY=aidlook.height>>1;
			aidlook.pivotX=aidlook.width>>1;
			aidlook.x=m_x;
			aidlook.y=m_y;
			aidlook.name = name;
			return aidlook;
		}
		
		private function LoadXML():void
		{
			ObjectData = new XML(); 
			var url:URLRequest = new URLRequest("res/GameData.xml");
			var myLoader:URLLoader = new URLLoader(url); 
			myLoader.addEventListener(flash.events.Event.COMPLETE, xmlLoaded); 
			function xmlLoaded(event:flash.events.Event):void 
			{ 
				ObjectData = XML(myLoader.data); 
				//var i:int = ObjectList.box[1].@width;
				//trace(i);
			}
		}
		
		public function get x():int{return m_x};
		public function get y():int{return m_y};
	}
}