package;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.text.FlxText;

/**
 * ...
 * @author Tiago Ling Alexandre
 */
class GameOverSubState extends FlxSubState
{
	var gameOverCam:FlxCamera;
	public var score:Int;
	public var waves:Int;
	
	override public function create() 
	{
		super.create();
		
		var gameOverCam = new FlxCamera(0, 0, 640, 512);
		gameOverCam.bgColor = 0x99000000;
		FlxG.cameras.add(gameOverCam);
		
		//this.bgColor = 0x99808080;
		
		var bigLabel = new FlxText(0, 120, 640, 'GAME OVER', 70);
		bigLabel.setFormat(AssetPaths.bitwise__ttf, 70);
		bigLabel.color = 0xFF009900;
		bigLabel.alignment = FlxTextAlign.CENTER;
		bigLabel.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0xFF333333);
		add(bigLabel);
		
		var instructionLabel = new FlxText(10, 250, 620, 'You managed to kill $waves roach waves and obtain $score points before letting the station explode', 24);
		instructionLabel.setFormat(AssetPaths.bitwise__ttf, 24);
		instructionLabel.color = 0xFF009900;
		instructionLabel.alignment = FlxTextAlign.CENTER;
		instructionLabel.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0xFF333333);
		add(instructionLabel);
		
		var controlBLabel = new FlxText(0, 400, 640, 'Press any key to restart the game', 18);
		controlBLabel.setFormat(AssetPaths.bitwise__ttf, 18);
		controlBLabel.color = 0xFF009900;
		controlBLabel.alignment = FlxTextAlign.CENTER;
		controlBLabel.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0xFF333333);
		add(controlBLabel);
	}
	
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (FlxG.keys.justPressed.ANY) {
			close();
			
			var pState = cast(_parentState, PlayState);
			pState.endGame();
		}
	}
	
	override public function destroy():Void
	{
		super.destroy();
		
		gameOverCam = null;
	}
	
}