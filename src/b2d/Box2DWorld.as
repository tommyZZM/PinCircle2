package b2d
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2World;
	import Box2D.Dynamics.Joints.b2DistanceJoint;
	import Box2D.Dynamics.Joints.b2DistanceJointDef;
	import Box2D.Dynamics.Joints.b2PrismaticJointDef;
	import Box2D.Dynamics.Joints.b2WeldJoint;
	import Box2D.Dynamics.Joints.b2WeldJointDef;
	
	//import b2d.events.ContactEvent;
	
	import starling.display.DisplayObject;
	import starling.events.EventDispatcher;
	
	import utils.Constants;
	
	//[Event(name="onContact", type="b2d.events.ContactEvent")]
	
	public class Box2DWorld extends EventDispatcher
	{
		public static var gworld:b2World;
		
		public function Box2DWorld()
		{
			super();
			var gravity:b2Vec2 = new b2Vec2(0., Constants.gravity);
			var doSleep:Boolean = true;
			gworld = new b2World(gravity,doSleep);
		}
		
		public function updateWorld():void
		{
			//TODO：每帧的时候
			gworld.Step(1 / 30, 8, 6);
			gworld.ClearForces();
		}
		
		public function updateBody():void
		{
			for (var body:b2Body = gworld.GetBodyList(); body ; body=body.GetNext()) 
			{				
				var sprite:DisplayObject = body.GetUserData() as DisplayObject;
				if (sprite) 
				{
					sprite.x = body.GetPosition().x * 30;
					sprite.y = body.GetPosition().y * 30;
					sprite.rotation = body.GetAngle();
				}
			}
		}
		
		public final function createPrismaticJointLite(bB:b2Body,align:b2Vec2):b2PrismaticJointDef
		{
			var bA:b2Body = gworld.GetGroundBody();
			var prismaticJointDef:b2PrismaticJointDef = new b2PrismaticJointDef();
			prismaticJointDef.collideConnected = true;
			prismaticJointDef.Initialize(bA,bB,bB.GetWorldCenter(), align);
			gworld.CreateJoint(prismaticJointDef);
			return prismaticJointDef;
		}
		
		public final function createDistanceJointLite(bA:b2Body,bB:b2Body,anchorA:b2Vec2,anchorB:b2Vec2):b2DistanceJoint
		{
			var DistanceJoint:b2DistanceJoint
			var DistanceJointDef:b2DistanceJointDef = new b2DistanceJointDef();
			DistanceJointDef.collideConnected = true;
			DistanceJointDef.Initialize(bA,bB,anchorA,anchorB);
			DistanceJoint = gworld.CreateJoint(DistanceJointDef)  as b2DistanceJoint;
			return DistanceJoint;
		}
		
		public final function createWeldJointLite(bA:b2Body,bB:b2Body,anchorB:b2Vec2):b2WeldJoint
		{
			var WeldJoint:b2WeldJoint;
			//var bA:b2Body = mworld.GetGroundBody();
			var JointDef:b2WeldJointDef = new b2WeldJointDef();
			JointDef.collideConnected = true;
			JointDef.Initialize(bA,bB,anchorB);
			WeldJoint = gworld.CreateJoint(JointDef) as b2WeldJoint;
			return WeldJoint;
		}
	}
}