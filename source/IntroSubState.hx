package;
import flixel.addons.text.FlxTypeText;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

/**
 * ...
 * @author Tiago Ling Alexandre
 */
class IntroSubState extends FlxSubState
{
	public var introCam:FlxCamera;
	var introLabel:flixel.addons.text.FlxTypeText;
	var timer:FlxTimer;
	var introOver:Bool;
	var skipLabel:FlxText;
	
	public function new(BGColor:FlxColor = 0)
	{
		super();
		
		introCam = new FlxCamera(0, 0, 640, 512);
		introCam.bgColor = 0x99000000;
		FlxG.cameras.add(introCam);
	}
	
	override public function create()
	{
		super.create();
		
		introOver = false;
		
		introLabel = new FlxTypeText(10, 150, FlxG.width - 20, "Maintenance unit AT-512, an infestation of acidic roaches was detected approaching your sector. If they pass through the ship's thermal exhaust port they will compromise the whole station. Initiate emergency protocol and commence defensive procedures. Protect the entrance vent at any cost. END OF TRANSMISSION", 12, true);
		introLabel.delay = 0.1;
		introLabel.eraseDelay = 0.2;
		introLabel.showCursor = true;
		introLabel.cursorBlinkSpeed = 1.0;
		introLabel.prefix = "> INCOMING MESSAGE : ";
		introLabel.autoErase = true;
		introLabel.waitTime = 2.0;
		introLabel.setTypingVariation(0.75, true);
		introLabel.sounds = [FlxG.sound.load(AssetPaths.text_type__wav)];
		introLabel.sounds[0].volume = 0.5;
		introLabel.setFormat(AssetPaths.bitwise__ttf, 24);
		introLabel.color = 0xFF009900;
		introLabel.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0xFF333333);
		introLabel.alignment = FlxTextAlign.CENTER;
		introLabel.skipKeys = ["SPACE"];
		introLabel.completeCallback = onIntroTextComplete;
		add(introLabel);
		
		skipLabel = new FlxText(0, 490, 640, '<SPACE> - Skip', 16);
		skipLabel.setFormat(AssetPaths.bitwise__ttf, 16);
		skipLabel.color = 0xFF009900;
		skipLabel.alignment = FlxTextAlign.CENTER;
		skipLabel.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0xFF333333);
		add(skipLabel);
		
		timer = new FlxTimer();
		timer.start(1, showIntro);
	}
	
	function flashScreen()
	{
		if (!introOver) {
			introCam.flash(0x66FF0000, 2, flashScreen);
			//Play alarm sound
			FlxG.sound.play(AssetPaths.intro_alarm__wav);
		}
	}
	
	function showIntro(t:FlxTimer) 
	{
		introCam.flash(0x66FF0000, 2, flashScreen);
		FlxG.sound.play(AssetPaths.intro_alarm__wav);
		introLabel.start(0.1, false, false);
	}
	
	function onIntroTextComplete() 
	{
		introLabel.cursorBlinkSpeed = 10;
		//Show Menu texts / effects if any
		timer.start(2, function (t:FlxTimer) {
			FlxTween.tween(introLabel, { alpha:0 }, 0.5, { type:FlxTween.ONESHOT, onComplete:showLogo } );
			FlxTween.tween(skipLabel, { alpha:0 }, 0.5, { type:FlxTween.ONESHOT, onComplete:showLogo } );
		});
	}
	
	function showLogo(t:FlxTween) 
	{
		FlxG.sound.play(AssetPaths.intro_weird_sfx__wav);
		
		var bigLabel = new FlxText(0, 120, 640, 'THE INFESTATION', 70);
		bigLabel.setFormat(AssetPaths.bitwise__ttf, 70);
		bigLabel.color = 0xFF009900;
		bigLabel.alignment = FlxTextAlign.CENTER;
		bigLabel.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0xFF333333);
		add(bigLabel);
		
		var instructionLabel = new FlxText(0, 250, 640, 'Press <SPACE> to Play', 24);
		instructionLabel.setFormat(AssetPaths.bitwise__ttf, 24);
		instructionLabel.color = 0xFF009900;
		instructionLabel.alignment = FlxTextAlign.CENTER;
		instructionLabel.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0xFF333333);
		add(instructionLabel);
		
		var controlALabel = new FlxText(0, 368, 640, 'In-game controls:', 14);
		controlALabel.setFormat(AssetPaths.bitwise__ttf, 14);
		controlALabel.color = 0xFF009900;
		controlALabel.alignment = FlxTextAlign.CENTER;
		controlALabel.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0xFF333333);
		add(controlALabel);
		
		var controlBLabel = new FlxText(0, 400, 640, '<ARROWS> - Move', 18);
		controlBLabel.setFormat(AssetPaths.bitwise__ttf, 18);
		controlBLabel.color = 0xFF009900;
		controlBLabel.alignment = FlxTextAlign.CENTER;
		controlBLabel.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0xFF333333);
		add(controlBLabel);
		
		var controlCLabel = new FlxText(0, 432, 640, '<SPACE> - Shoot', 18);
		controlCLabel.setFormat(AssetPaths.bitwise__ttf, 18);
		controlCLabel.color = 0xFF009900;
		controlCLabel.alignment = FlxTextAlign.CENTER;
		controlCLabel.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0xFF333333);
		add(controlCLabel);
		
		var creditsLabel = new FlxText(0, 490, 640, 'A game by Tiago Ling Alexandre for Ludum Dare 31', 16);
		creditsLabel.setFormat(AssetPaths.bitwise__ttf, 16);
		creditsLabel.color = 0xFF009900;
		creditsLabel.alignment = FlxTextAlign.CENTER;
		creditsLabel.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0xFF333333);
		add(creditsLabel);
		
		introOver = true;
	}
	
	override public function destroy():Void
	{
		super.destroy();
		
		introLabel = null;
		skipLabel = null;
		timer = null;
		introCam = null;
	}
	
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (FlxG.keys.justPressed.SPACE && introOver) {
			FlxG.sound.play(AssetPaths.pwp_get__wav);
			var pState = cast(_parentState, PlayState);
			pState.startGame();
			FlxG.cameras.remove(introCam);
			close();
		}
	}
}