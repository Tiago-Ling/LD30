package;
import flixel.effects.FlxFlicker;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;

/**
 * ...
 * @author Tiago Ling Alexandre
 */
class Powerup extends FlxSprite
{
	public var type:Int;
	var timer:FlxTimer;
	
	public function new(X:Float, Y:Float, ?SimpleGraphic:FlxGraphicAsset) 
	{
		super(X, Y, SimpleGraphic);
		
		type = -1;
		timer = new FlxTimer();
		
		loadGraphic(AssetPaths.pwps__png, true, 32, 32);
		animation.add("bomb", [0]);
		animation.add("vent", [1]);
		animation.add("life", [2]);
		animation.add("weapon", [3]);
		kill();
	}
	
	public function setType() 
	{
		type = FlxG.random.int(0, 3);
		
		switch (type) {
			case 0:	//Player life
				animation.play("life");
			case 1:	//Mega bomb
				animation.play("bomb");
			case 2:	//Rate of fire - put countdown timer over player position
				animation.play("weapon");
			case 3:	//Vent repair
				animation.play("vent");
		}
		
		this.visible = true;
		
		timer.start(4, function (t:FlxTimer) {
			FlxSpriteUtil.flicker(this, 3, 0.04, true, true, function (f:FlxFlicker) {
				disableAndKill();
			} );
		} );
	}
	
	public function disableAndKill()
	{
		timer.cancel();
		kill();
	}
	
	override public function destroy():Void
	{
		super.destroy();
		
		timer = null;
	}
}