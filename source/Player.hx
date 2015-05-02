package;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

/**
 * ...
 * @author Tiago Ling Alexandre
 */
class Player extends FlxSprite
{
	var timer:FlxTimer;
	var timeLeft:Int;
	var hasPwp:Bool;
	
	public var fireRate:Float;
	public var timeLabel:FlxText;
	
	public function new(X:Float, Y:Float, ?SimpleGraphic:FlxGraphicAsset) {
		super(X, Y, SimpleGraphic);
		
		init();
	}
	
	function init()
	{
		//loadGraphic(AssetPaths.robot__png, true, 32, 32);
		loadRotatedGraphic(AssetPaths.robot__png);
		
		fireRate = 0.2;
		timeLeft = 0;
		hasPwp = false;
		
		timer = new FlxTimer();
		timeLabel = new FlxText(0, 0, 120, '00:00', 12);
		timeLabel.color = FlxColor.YELLOW;
		timeLabel.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0x333333, 1);
		timeLabel.alignment = FlxTextAlign.CENTER;
		timeLabel.font = AssetPaths.bitwise__ttf;
		timeLabel.kill();
	}
	
	public function doubleFireRate() {
		
		hasPwp = true;
		timeLeft = 10;
		fireRate = 0.1;
		timeLabel.revive();
		timeLabel.setPosition((this.x + this.width / 2) - (timeLabel.width / 2), this.y - 5);
		timeLabel.text = '00:$timeLeft';
		timeLabel.alpha = 1;
		timer.start(1, function(t:FlxTimer) {
			timeLeft--;
			if (timeLeft > 9)
				timeLabel.text = '00:$timeLeft';
			else
				timeLabel.text = '00:0$timeLeft';
			
			if (t.loopsLeft == 0) {
				hasPwp = false;
				FlxTween.tween(timeLabel, { alpha:0 }, 0.3, { type:FlxTween.ONESHOT, onComplete:function (t:FlxTween) { timeLabel.kill(); } } );
				fireRate = 0.2;
			}
		},timeLeft);
	}
	
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (hasPwp) {
			timeLabel.setPosition((this.x + this.width / 2) - (timeLabel.width / 2), this.y - 5);
		}
	}
	
	
	override public function destroy()
	{
		super.destroy();
		
		timer = null;
		timeLabel = null;
	}
}