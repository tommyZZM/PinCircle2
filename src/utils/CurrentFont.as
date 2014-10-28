/**
 *
 * Hungry Hero Game
 * http://www.hungryherogame.com
 * 
 * Copyright (c) 2012 Hemanth Sharma (www.hsharma.com). All rights reserved.
 * 
 * This ActionScript source code is free.
 * You can redistribute and/or modify it in accordance with the
 * terms of the accompanying Simplified BSD License Agreement.
 *  
 */

package utils  
{
	
	import starling.text.BitmapFont;
	import starling.text.TextField;
	import starling.textures.Texture;

	/**
	 * This class embeds the bitmap fonts used in the game. 
	 * 
	 * @author hsharma
	 * 
	 */
	public class CurrentFont
	{
		/**
		 * Font for score value. 
		 */		
		[Embed(source="../res_game/fonts/fontScoreValue.png")]
		public static const Font_ScoreValue:Class;
		
		[Embed(source="../res_game/fonts/fontScoreValue.fnt", mimeType="application/octet-stream")]
		public static const XML_ScoreValue:Class;
		
		/**
		 * Font objects.
		 */
		private static var Regular:BitmapFont;
		private static var ScoreLabel:BitmapFont;
		private static var ScoreValue:BitmapFont;
		
		/**
		 * Returns the BitmapFont (texture + xml) instance's fontName property (there is only oneinstance per app).
		 * @return String 
		 */
		public static function getFont(_fontStyle:String):Font
		{
			if (CurrentFont[_fontStyle] == undefined)
			{
				var texture:Texture = Texture.fromBitmap(new CurrentFont["Font_" + _fontStyle]());
				var xml:XML = XML(new CurrentFont["XML_" + _fontStyle]());
				CurrentFont[_fontStyle] = new BitmapFont(texture, xml);
				TextField.registerBitmapFont(CurrentFont[_fontStyle]);
			}
			
			return new Font(CurrentFont[_fontStyle].name, CurrentFont[_fontStyle].size);
		}
	}
}
