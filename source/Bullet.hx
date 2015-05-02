package ;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxPath;

class Bullet extends FlxSprite {
	
	public var path:FlxPath;
	
	public function new (X:Float, Y:Float, ?SimpleGraphic:FlxGraphicAsset) {
		super(X, Y, SimpleGraphic);
		
		path = new FlxPath();
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		if (this.x < -this.width || this.x > FlxG.stage.stageWidth || this.y < -this.height || this.y > FlxG.stage.stageHeight) {
			velocity.set(0, 0);
			kill();
		}
	}
	
	override public function destroy():Void
	{
		super.destroy();
		
		path = null;
	}
}