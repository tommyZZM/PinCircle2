package
{
	import b2d.Box2DScene;
	
	import starling.core.Starling;
	import starling.display.ButtonEx;
	import starling.display.Image;
	import starling.events.Event;
	
	import utils.Constants;
	
	public class About extends Box2DScene
	{
		private var about:Image = new Image(Game.assets.getTexture("About"));
		
		public function About()
		{
			super();
			about.pivotX=about.width>>1;
			about.pivotY=about.height>>1;
			about.x = Constants.CenterX;
			about.y = Constants.CenterY-26;
			addChild(about);
			newButton("button_medium","backButton",Constants.CenterX,Constants.CenterY+96,"返回",Game.assets);//Button
			
			addChild(Constants.info());
		}
		
		private function onButtonUp(event:Event):void
		{
			var button:ButtonEx = event.target as ButtonEx;
			
		}
	}
}