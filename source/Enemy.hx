package ;

import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxTimer;

class Enemy extends FlxSprite {
	
	public var emitter:FlxEmitter;
	var timer:FlxTimer;
	
	public function new(X:Float, Y:Float, ?SimpleGraphic:FlxGraphicAsset) {
		super(X, Y, SimpleGraphic);

		loadGraphic(AssetPaths.roach__png, true, 32, 32);

		animation.add("walk", [0,1,2,3], 8, true);
		animation.add("hit", [4,5,6,7,8,9,10,11,12], 30, false);
		animation.play("walk");

		health = 100;

		animation.finishCallback = onAnimationEnded;
	}
	
	public function init()
	{
		emitter = new flixel.effects.particles.FlxEmitter(0, 0, 10);
		emitter.launchMode = FlxEmitterMode.CIRCLE;
		emitter.lifespan.set(0.1, 0.4);
		emitter.scale.set(0.4, 0.4, 0.8, 0.8, 1.2, 1.2, 1.5, 1.5);
		for (i in 0...10) {
			var part = new FlxParticle();
			
			part.loadGraphic(AssetPaths.roach_goo__png, true, 16, 16);
			part.animation.add("idle", [0, 1, 2, 3, 4, 5], 12, true);
			part.animation.play("idle");
			part.set_camera(this.camera);
			part.accelerationRange.set(FlxPoint.weak(0, 0), FlxPoint.weak(1, 1));
			part.velocityRange.set(FlxPoint.weak(0, 0), FlxPoint.weak(1, 1));
			part.scaleRange.set(FlxPoint.weak(0.2, 0.2), FlxPoint.weak(1.2, 1.2));
			part.angularVelocityRange.set(0, 1);
			emitter.add(part);
		}
		
		timer = new FlxTimer();
	}
	
	public function die(x:Float, y:Float) {
		emitter.setPosition(x, y);
		emitter.start(true, 0.1, 10);
		kill();
	}
	
	function onAnimationEnded(name:String) {
		if (name == "hit") {
			animation.play("walk");
		}
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
		
		timer = null;
		emitter = null;
	}
}