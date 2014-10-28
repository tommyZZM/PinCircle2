package b2d.events
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2ContactListener;
	import Box2D.Dynamics.b2World;
	import Box2D.Dynamics.Contacts.b2Contact;
	
	import b2d.Box2DScene;
	
	public class ContactEvent extends b2ContactListener
	{
		private var m_world:b2World;
		
		public function ContactEvent(world:b2World)
		{
			m_world = world
			super();
		}
		
		public override function BeginContact(contact:b2Contact):void
		{
			var Aname:String = contact.GetFixtureA().GetBody().GetUserData().name
			var Bname:String = contact.GetFixtureB().GetBody().GetUserData().name
			if (Aname =="bezel") 
			{
				if (Bname=="circle"){
					var contactx:Number = (contact.GetFixtureA().GetBody().GetPosition().x-contact.GetFixtureB().GetBody().GetPosition().x)*30;
					//trace(contactx);
					var pos:Number = -contactx/(contact.GetFixtureA().GetBody().GetUserData().width>>1);
					//trace(pos);
					
					var velocity0x:Number = contact.GetFixtureB().GetBody().GetLinearVelocity().x;
					var velocity0y:Number = contact.GetFixtureB().GetBody().GetLinearVelocity().y;
					
					var angle:Number = Math.PI *1 + (Math.random() * Math.PI * pos)*0.1;
					var velocity:b2Vec2 = new b2Vec2(Math.sin(angle), Math.cos(angle));
					
					//contact.GetFixtureB().GetBody().SetLinearVelocity(velocity);
				}
			}
				
		}
		
		public override function EndContact(contact:b2Contact):void
		{
			var Aname:String = contact.GetFixtureA().GetBody().GetUserData().name
			var Bname:String = contact.GetFixtureB().GetBody().GetUserData().name
			if (Aname =="brickR" || Aname =="brickO" || Aname =="brickB") 
			{
				contact.GetFixtureA().GetBody().GetUserData().visible = false;
				if (Bname=="circle"){
					switch(Aname)
					{
						case "brickR":
						{
							InGame.GameScore++;
							break;
						}
						case "brickO":
						{
							InGame.GameScore+=5;
							break;
						}
						case "brickB":
						{
							InGame.GameScore+=10;
							break;
						}
					}
				}
			}
			
			if (Bname =="brickR" || Bname =="brickO" || Bname =="brickB") 
			{
				contact.GetFixtureB().GetBody().GetUserData().visible = false;
				Box2DScene.b2dworld.DestroyBody(contact.GetFixtureB().GetBody());
			}
		}
		
	}
}