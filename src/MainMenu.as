package
{
	import flash.utils.getQualifiedClassName;
	
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	
	import utils.Constants;
	
	public class MainMenu extends Sprite
	{
		public function MainMenu()
		{
			super();
			init();
		}
		
		private function init():void
		{
			var logo:Image = new Image(Game.assets.getTexture("logo"));
			addChild(logo);
			
			var scenesToCreate:Array = [
				["Start", InGame],
				["About", About]
			];
			
			var buttonTexture:Texture = Game.assets.getTexture("button_medium");
			var count:int = 0;
			
			for each (var sceneToCreate:Array in scenesToCreate)//对scenesToCreate每个元素处理
			{
				var sceneTitle:String = sceneToCreate[0];
				var sceneClass:Class  = sceneToCreate[1];
				
				var button:Button = new Button(buttonTexture, sceneTitle);//创建一个按钮实例，设置它的up和down状态的纹理，以及文本。 
				var buttonCentreX:int=(Constants.CenterX)-(button.width>>1);
				var buttonCentreY:int=((Constants.CenterY)-(button.height>>1))+10;
				button.x = buttonCentreX;//三元条件运算符 (boolean?true:false)
				button.y = count%2 ==0? buttonCentreY-29:buttonCentreY+29;
				button.name = getQualifiedClassName(sceneClass);
				addChild(button);
				
				//如果是基数y就加24(基数按钮在右侧)
				if (scenesToCreate.length % 2 != 0 && count % 2 == 1)
					button.y += 24;
				
				++count;
			}
			
			addChild(Constants.info());
		}
	}
}