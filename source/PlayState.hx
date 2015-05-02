package;

import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxColor;
import flixel.util.FlxColor;
import flixel.util.FlxPath;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	static inline var PLAYER_SPEED:Float = 300;
	
	static inline var BULLET_SPEED:Float = 300;
	static inline var B_SPD_X_MODIFIER_SMALL:Float = 0.65;
	static inline var B_SPD_Y_MODIFIER_SMALL:Float = 0.34;
	static inline var B_SPD_X_MODIFIER_BIG:Float = 1.3;
	static inline var B_SPD_Y_MODIFIER_BIG:Float = 0.68;
	
	static inline var SPAWN_INTERVAL:Float = 1;
	static inline var ENEMY_SPEED:Float = 20;
	
	static inline var PWP_INTERVAL:Float = 5;
	static inline var PWP_CHANCE:Int = 50;
	
	var scrWidth:Int;
	var scrHeight:Int;
	
	var player:Player;
	var wall:Wall;
	var bullets:FlxTypedGroup<Bullet>;
	var canFire:Bool;
	var fireTimer:FlxTimer;

	var enemyTimer:FlxTimer;
	var enemies:FlxTypedGroup<Enemy>;
	var spawnTimer:FlxTimer;
	var lastWavePosition:Array<Int>;

	var numWaves:Int;
	var wavesLabel:FlxText;
	var fixedWaveTime:Float;
	var extraWaveTime:Float;

	var shields:FlxTypedGroup<FlxSprite>;

	var frame_small:FlxObject;
	var frame_big:FlxObject;

	var initialWallPress:Wall;
	
	var playerHealthLabel:FlxText;
	var pDmgTimer:FlxTimer;
	var pwpTimer:FlxTimer;
	var vDmgTimer:FlxTimer;
	var ventDamageLabel:flixel.text.FlxText;
	var ventDmg:Int;
	
	var scoreLabel:FlxText;
	var score:Int;
	
	var scrCenter:FlxPoint;
	
	var gameCam:FlxCamera;
	var hudCam:FlxCamera;
	
	var gameOn:Bool;
	
	var powerups:FlxTypedGroup<Powerup>;
	var pwpChance:Float;
	var pwpLabel:FlxText;
	
	override public function create():Void
	{
		super.create();
		
		FlxG.sound.volume = 0.5;
		
		scrCenter = FlxPoint.get(FlxG.width / 2, FlxG.height / 2);
		FlxG.mouse.visible = false;
		
		score = 0;
		gameOn = false;
		pwpChance = 40;
		
		fixedWaveTime = 5;
		extraWaveTime = 4;
		lastWavePosition = [];
		
		#if html5
		scrWidth = 640;
		scrHeight = 512;
		#else
		scrWidth = FlxG.stage.stageWidth;
		scrHeight = FlxG.stage.stageHeight;
		#end

		//0 - Right | 1 - Bottom | 2 - Left | 3 - Top
		wall = Wall.Bottom;
		
		gameCam = new FlxCamera(0, 0, 640, 512);
		FlxG.cameras.add(gameCam);
		
		var bg = new FlxSprite(0, 32);
		bg.loadGraphic(AssetPaths.background__png);
		bg.set_camera(gameCam);
		add(bg);

		var totalBullets = 75;
		bullets = new FlxTypedGroup<Bullet>(totalBullets);
		for (i in 0...totalBullets) {
			var bullet = new Bullet(0, 0);
			bullet.makeGraphic(2, 6, FlxColor.RED);
			bullet.set_camera(gameCam);
			bullet.kill();
			bullets.add(bullet);
		}
		add(bullets);

		numWaves = 0;
		var totalEnemies = 50;
		enemies = new FlxTypedGroup<Enemy>(totalEnemies);
		for (i in 0...totalEnemies) {
			var enemy = new Enemy(0, 0);
			enemy.set_camera(gameCam);
			enemy.init();
			enemy.kill();
			enemies.add(enemy);
			enemy.emitter.set_camera(gameCam);
			add(enemy.emitter);
		}
		add(enemies);
		enemyTimer = new FlxTimer();
		spawnTimer = new FlxTimer();

		canFire = true;
		fireTimer = new FlxTimer();

		shields = new FlxTypedGroup<FlxSprite>();
		for (i in 0...4) {
			var shield = new FlxSprite(0, 0);
			var x:Float = 0;
			var y:Float = 0;
			switch (i) {
				case 0:	//Right
					shield.makeGraphic(32, 416, FlxColor.WHITE);
					x = scrWidth;
					y = shield.width;
				case 1:	//Bottom
					shield.makeGraphic(576, 32, FlxColor.WHITE);
					x = shield.height;
					y = scrHeight;
				case 2:	//Left
					shield.makeGraphic(32, 416, FlxColor.WHITE);
					x = -shield.width;
					y = shield.width;
				case 3:	//Top
					shield.makeGraphic(576, 32, FlxColor.WHITE);
					x = shield.height;
					y = -shield.height;
			}
			shield.immovable = true;
			shield.setPosition(x, y);
			shields.add(shield);
		}
		add(shields);

		player = new Player(0, 0);
		player.health = 100;
		player.set_camera(gameCam);
		player.timeLabel.set_camera(gameCam);

		player.setPosition(scrWidth / 2 - player.width / 2, 480);

		frame_small = new FlxObject(240, 212, 160, 120);
		#if debug
		frame_small.debugBoundingBoxColor = 0xFFFFFFFF;
		#end
		add(frame_small);
		
		frame_big = new FlxObject(160, 155, 320, 234);
		#if debug
		frame_big.debugBoundingBoxColor = 0xFF00CC00;
		#end
		add(frame_big);
		
		hudCam = new FlxCamera(0, 0, 640, 512);
		hudCam.bgColor = 0x0000000;
		FlxG.cameras.add(hudCam);
		
		var textSize = 18;
		playerHealthLabel = new FlxText(10, 5, 120, 'Player : ${player.health}', textSize);
		playerHealthLabel.color = 0x352B7A;
		playerHealthLabel.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0x9C95CB, 1);
		playerHealthLabel.alignment = FlxTextAlign.CENTER;
		playerHealthLabel.font = AssetPaths.bitwise__ttf;
		playerHealthLabel.cameras = [hudCam];
		
		ventDmg = 0;
		ventDamageLabel = new FlxText(130, 5, 220, 'Vent Damage : ${ventDmg}%', textSize);
		ventDamageLabel.color = 0x126F0D;
		ventDamageLabel.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0x333333, 1);
		ventDamageLabel.alignment = FlxTextAlign.CENTER;
		ventDamageLabel.font = AssetPaths.bitwise__ttf;
		ventDamageLabel.cameras = [hudCam];
		
		pDmgTimer = new FlxTimer();
		vDmgTimer = new FlxTimer();
		pwpTimer = new FlxTimer();
		
		powerups = new FlxTypedGroup<Powerup>();
		for (i in 0...10) {
			var pwp = new Powerup(0, 0);
			powerups.add(pwp);
		}
		add(powerups);
		
		scoreLabel = new FlxText(scrWidth - 190, 5, 180, 'Score : $score', textSize);
		scoreLabel.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0x333333, 1);
		scoreLabel.alignment = FlxTextAlign.RIGHT;
		scoreLabel.font = AssetPaths.bitwise__ttf;
		scoreLabel.cameras = [hudCam];
		
		wavesLabel = new FlxText(scrCenter.x + 20, 5, 120, 'Waves : $numWaves', textSize);
		wavesLabel.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0x333333, 1);
		wavesLabel.alignment = FlxTextAlign.CENTER;
		wavesLabel.font = AssetPaths.bitwise__ttf;
		wavesLabel.cameras = [hudCam];
		
		pwpLabel = new FlxText(0, 256, 640, 'Fire Rate Up!', 32);
		pwpLabel.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0x333333, 1);
		pwpLabel.alignment = FlxTextAlign.CENTER;
		pwpLabel.font = AssetPaths.bitwise__ttf;
		pwpLabel.cameras = [hudCam];
		pwpLabel.alpha = 0;
		
		var introSubState = new IntroSubState(0x000000);
		openSubState(introSubState);
	}
	
	public function startGame()
	{
		spawnEnemyWave(enemyTimer);
		enemyTimer.start(fixedWaveTime + extraWaveTime, spawnEnemyWave);
		
		pwpTimer.start(10, onPowerUpTimer,0);
		
		add(player);
		add(player.timeLabel);
		add(playerHealthLabel);
		add(ventDamageLabel);
		add(scoreLabel);
		add(wavesLabel);
		add(pwpLabel);
		
		var t = new FlxTimer();
		t.start(0.3, function (t:FlxTimer) { gameOn = true; } );
	}
	
	public function endGame()
	{
		FlxG.resetGame();
	}
	
	function onPowerUpTimer(t:FlxTimer)
	{
		if (!FlxG.random.bool(pwpChance)) {
			trace('Placing powerup FAIL');
			pwpChance += 5;
			return;
		} else {
			trace('Placing powerup');
			pwpChance = 40;
			
			var pwp = powerups.recycle();
			pwp.setType();
			
			//Never spawn in the same wall as the player
			var excludes:Array<Int> = [];
			switch(wall) {
				case Wall.Right:
					excludes = [0];
				case Wall.Bottom:
					excludes = [1];
				case Wall.Left:
					excludes = [2];
				case Wall.Top:
					excludes = [3];
			}
			
			var wallToPlace = FlxG.random.int(0, 3, excludes);
			switch (wallToPlace) {
				case 0:	//Right //15
					pwp.setPosition(0, (FlxG.random.int(0, 14) * 32) + 32);
				case 1:	//Bottom //20
					pwp.setPosition(FlxG.random.int(0, 19) * 32, scrHeight - pwp.height);
				case 2:	//Left
					pwp.setPosition(scrWidth - pwp.width, (FlxG.random.int(0, 14) * 32) + 32);
				case 3:	//Top
					pwp.setPosition(FlxG.random.int(0, 19) * 32, 32);
			}
			
			pwp.scale.set(0.25, 0.25);
			pwp.revive();
			FlxTween.tween(pwp.scale, { x:1, y:1 }, 0.3, { type:FlxTween.ONESHOT, ease:FlxEase.quintOut } );
			FlxG.sound.play(AssetPaths.pwp_appear__wav);
		}
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
		
		player = null;
		wall = null;
		bullets = null;
		fireTimer = null;

		enemyTimer = null;
		enemies = null;
		spawnTimer = null;
		lastWavePosition = null;

		wavesLabel = null;

		shields = null;

		frame_small = null;
		frame_big = null;

		initialWallPress = null;
		
		playerHealthLabel = null;
		pDmgTimer = null;
		pwpTimer = null;
		vDmgTimer = null;
		ventDamageLabel = null;
		
		scoreLabel = null;
		
		scrCenter = null;
		
		gameCam = null;
		hudCam = null;
	}

	/**
	 * Function that is called once every frame_small.
	 */
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		if (player.health <= 0 || ventDmg >= 100) {
			FlxG.sound.play(AssetPaths.game_over__wav);
			gameCam.fade(0xBB000000, 0.5, false, function () { 
				
				enemyTimer.cancel();
				fireTimer.cancel();
				pDmgTimer.cancel();
				pwpTimer.cancel();
				spawnTimer.cancel();
				vDmgTimer.cancel();
				player.kill();
				for (member in enemies.members) {
					if (member.alive) {
						member.die(member.x + member.width / 2, member.y + member.height / 2);
					}
				}
				
				powerups.kill();
				bullets.kill();
				
				var gameOver = new GameOverSubState();
				gameOver.score = score;
				gameOver.waves = numWaves;
				openSubState(gameOver);
				
			} );
		}

		checkCollisions();

		checkPosition();

		handleInput();
	}

	function checkCollisions()
	{
		FlxG.collide(enemies, shields, function (a:Enemy, b:FlxSprite) {
			
			a.kill();
			FlxG.camera.flash(FlxColor.WHITE, 0.2);
			
			var dmg = FlxG.random.int(0, 8) + 2;
			setVentLife(dmg, false);
		});

		FlxG.overlap(bullets, enemies, function (a:Bullet, b:Enemy) {
			a.kill();
			b.health -= 25;			
			if (b.health <= 0) {
				FlxG.sound.play(AssetPaths.enemy_death__wav);
				score += 50;
				scoreLabel.text = 'Score : $score';
				b.die(b.x + b.width / 2, b.y + b.height / 2);
			} else {
				b.animation.play("hit");
				FlxG.sound.play(AssetPaths.enemy_dmg__wav);
				FlxTween.tween(b.scale, { x:1.2, y:1.2 }, 0.1, { type:FlxTween.ONESHOT, ease:FlxEase.quintIn, onComplete:function (t:FlxTween) {
					FlxTween.tween(b.scale, { x:1, y:1 }, 0.1, { type:FlxTween.ONESHOT, ease:FlxEase.quintOut } );
				} } );
			}
		});

		FlxG.overlap(bullets, frame_small, function (a:Bullet, b:FlxObject) {
			a.kill();
		});
		
		FlxG.overlap(player, enemies, function (a:FlxSprite, b:Enemy) {
			b.die(b.x + b.width / 2, b.y + b.height / 2);
			gameCam.shake(0.01, 0.1);
			var dmg = FlxG.random.int(0, 5) + 2;
			setPlayerLife(dmg, false);
		});
		
		FlxG.overlap(player, powerups, function (a:FlxSprite, b:Powerup) {
			b.disableAndKill();
			pwpLabel.scale.set(0.25, 0.25);
			switch (b.type) {
				case 0:	//Blue - Player life
					pwpLabel.color = FlxColor.BLUE;
					pwpLabel.text = 'AT-512 Energy Up!';
					var life = FlxG.random.int(0, 8) + 2;
					setPlayerLife(life, true);
				case 1:	//Red - Mega bomb
					pwpLabel.color = FlxColor.RED;
					pwpLabel.text = 'Mega Bomb!!!';
					FlxG.sound.play(AssetPaths.bomb__wav);
					for (member in enemies.members) {
						if (member.alive) {
							member.die(member.x + member.width / 2, member.y + member.height / 2);
						}
					}
				case 2:	//Yellow - Rate of fire - put countdown timer over player position
					pwpLabel.color = FlxColor.YELLOW;
					pwpLabel.text = 'Fire Rate Up!';
					player.doubleFireRate();
					FlxG.sound.play(AssetPaths.pwp_get__wav);
				case 3:	//Green - Vent repair
					pwpLabel.color = FlxColor.GREEN;
					pwpLabel.text = 'Vent Damage Down!';
					var life = FlxG.random.int(0, 8) + 2;
					setVentLife(life, true);
					
			}
			pwpLabel.alpha = 1;
			FlxTween.tween(pwpLabel.scale, { x:1.25, y:1.25 }, 0.3, { type:FlxTween.ONESHOT, ease:FlxEase.quintOut, onComplete:function (t:FlxTween) {
				FlxTween.tween(pwpLabel.scale, { x:1, y:1 }, 0.2, { type:FlxTween.ONESHOT, ease:FlxEase.quintIn } );
				FlxTween.tween(pwpLabel, { alpha:0 }, 0.5, { type:FlxTween.ONESHOT, startDelay:0.3 } );
			}});
		});
	}
	
	function setPlayerLife(value:Int, add:Bool)
	{
		if (add)
			FlxG.sound.play(AssetPaths.pwp_get__wav);	//Play good sfx
		else
			FlxG.sound.play(AssetPaths.player_dmg__wav);
		
		var tweenTime = (value * 0.08) / 2;
		FlxTween.tween(playerHealthLabel.scale, { x:1.2, y:1.2 }, tweenTime, { type:FlxTween.ONESHOT, ease:FlxEase.quintIn, onComplete:function (t:FlxTween) {
			FlxTween.tween(playerHealthLabel.scale, { x:1, y:1 }, tweenTime, { type:FlxTween.ONESHOT, ease:FlxEase.quintOut } );
		} } );
		pDmgTimer.start(0.15, function (t:FlxTimer) {
			if (add && player.health < 100)
				player.health++;
			else if (!add && player.health > 0)
				player.health--;
				
			playerHealthLabel.text = 'Player : ${player.health}';
		}, value);
	}
	
	//Add = reduce damage
	function setVentLife(value:Int, add:Bool)
	{
		if (add)
			FlxG.sound.play(AssetPaths.pwp_get__wav);	//Play good sfx
		else
			FlxG.sound.play(AssetPaths.vent_dmg__wav);
		
		var tweenTime = (value * 0.08) / 2;
		FlxTween.tween(ventDamageLabel.scale, { x:1.2, y:1.2 }, tweenTime, { type:FlxTween.ONESHOT, ease:FlxEase.quintIn, onComplete:function (t:FlxTween) {
			FlxTween.tween(ventDamageLabel.scale, { x:1, y:1 }, tweenTime, { type:FlxTween.ONESHOT, ease:FlxEase.quintOut } );
		} } );
		vDmgTimer.start(0.15, function (t:FlxTimer) {
			if (add && ventDmg > 0)
				ventDmg--;
			else if (!add && ventDmg < 100)
				ventDmg++;
				
			ventDamageLabel.text = 'Vent Damage : ${ventDmg}%';
		}, value);
	}

	function checkPosition()
	{
		if (player.x <= 0 && player.velocity.x < 0) {
			player.x = 0;
			wall = Wall.Left;
			player.angle = 90;
		}

		if (player.x >= (scrWidth - player.width) && player.velocity.x > 0) {
			player.x = scrWidth - player.width;
			wall = Wall.Right;
			player.angle = 270;
		}

		if (player.y <= 32 && player.velocity.y < 0) {
			player.y = 32;
			wall = Wall.Top;
			player.angle = 180;
		}

		if (player.y >= (scrHeight - player.height) && player.velocity.y > 0) {
			player.y = scrHeight - player.height;
			wall = Wall.Bottom;
			player.angle = 0;
		}
		
	}

	function handleInput()
	{
		if (!gameOn)
			return;
			
		if (FlxG.keys.pressed.LEFT && (wall == Wall.Top || wall == Wall.Bottom)) {
			player.velocity.x = -PLAYER_SPEED;
		}
		
		if (FlxG.keys.pressed.RIGHT && (wall == Wall.Top || wall == Wall.Bottom)) {
			player.velocity.x = PLAYER_SPEED;
		}
		
		if (FlxG.keys.pressed.UP && (wall == Wall.Left || wall == Wall.Right)) {
			player.velocity.y = -PLAYER_SPEED;
		}
		
		if (FlxG.keys.pressed.DOWN && (wall == Wall.Left || wall == Wall.Right)) {
			player.velocity.y = PLAYER_SPEED;
		}

		if (FlxG.keys.pressed.SPACE && canFire) {
			
			canFire = false;
			fireTimer.start(player.fireRate,function (t:FlxTimer) {
				canFire = true;
			});

			var bullet = bullets.getFirstDead();
			if (bullet != null) {
				switch (wall) {
					case Wall.Right:
						bullet.setPosition(player.x, player.y + (player.height / 2 - bullet.height / 2));
						bullet.angle = 90;
						bullet.revive();
					case Wall.Bottom:
						bullet.setPosition(player.x + (player.width / 2 - bullet.width / 2), player.y);
						bullet.angle = 0;
						bullet.revive();
					case Wall.Left:
						bullet.setPosition(player.x + player.width, player.y + (player.height / 2 - bullet.height / 2));
						bullet.revive();
					case Wall.Top:
						bullet.setPosition(player.x + (player.width / 2 - bullet.width / 2), player.y + player.height);
						bullet.revive();
				}
				
				bullet.path.start(bullet, [scrCenter], BULLET_SPEED, FlxPath.FORWARD, true);
				FlxG.sound.play(AssetPaths.player_shot__wav);
			}
		}
		
/*		if (FlxG.keys.pressed.E) {
			player.health = 0;
		}
		
		if (FlxG.keys.pressed.R) {
			player.doubleFireRate();
		}*/

		if (FlxG.keys.justReleased.ANY) {
			player.velocity.set(0, 0);
		}
	}

	function spawnEnemyWave(t:FlxTimer) {
		
		var wall = -1;
		
		if (lastWavePosition.length > 0)
			wall = FlxG.random.int(0, 3, lastWavePosition);
		else
			wall = FlxG.random.int(0, 3);
		
		lastWavePosition = [wall];
		
		//trace('Spawning wave : $numWaves | direction : $wall');
		wavesLabel.text = 'Waves : $numWaves';
		
		var numEnemies = 0;
		var spawnInterval = SPAWN_INTERVAL;	//1
		var enemySpeed = ENEMY_SPEED;	//20
		
		extraWaveTime -= 0.2;

		if (numWaves < 3) {
			numEnemies = 9;
			spawnInterval -= 0.1;
			enemySpeed += 2;
		} else if (numWaves < 5) {
			numEnemies = 12;
			spawnInterval -= 0.2;
			enemySpeed += 4;
		} else if (numWaves < 8) {
			numEnemies = 15;
			spawnInterval -= 0.3;
			enemySpeed += 6;
		} else if (numWaves < 12) {
			numEnemies = 19;
			spawnInterval -= 0.4;
			enemySpeed += 8;
		} else if (numWaves < 15) {
			numEnemies = 23;
			spawnInterval -= 0.4;
			enemySpeed += 12;
		} else {
			numEnemies = 27;
			spawnInterval -= 0.5;
			enemySpeed += 15;
		}

		spawnTimer.start(spawnInterval, function (t:FlxTimer) {
			var enemy = enemies.getFirstDead();
			var x:Float = 0;
			var y:Float = 0;
			if (enemy != null) {
				enemy.velocity.set(0, 0);
				enemy.health = 100;
				switch (wall) {
					case 0:	//Right
						x = frame_small.x;
						var slot = FlxG.random.int(0, 2); 
						y = frame_small.y + slot * 40;
						enemy.velocity.x = -enemySpeed;
						enemy.angle = 270;

						if (slot < 3)
							enemy.velocity.y = -enemySpeed / 2;
						else if (slot == 3)
							enemy.velocity.y = 0;
						else
							enemy.velocity.y = enemySpeed / 2;

					case 1:	//Bottom
						var slot = FlxG.random.int(0, 4);
						x = frame_small.x + slot * 32;
						y = frame_small.y;
						enemy.velocity.y = -enemySpeed;

						if (slot < 4)
							enemy.velocity.x = -enemySpeed / 2;
						else if (slot == 4)
							enemy.velocity.x = 0;
						else
							enemy.velocity.x = enemySpeed / 2;

						enemy.angle = 0;
					case 2:	//Left
						x = (frame_small.x + frame_small.width) - enemy.width;
						var slot = FlxG.random.int(0, 2) * 40;
						y = y = frame_small.y + slot;
						enemy.velocity.x = enemySpeed;
						enemy.angle = 90;

						if (slot < 3)
							enemy.velocity.y = -enemySpeed / 2;
						else if (slot == 3)
							enemy.velocity.y = 0;
						else
							enemy.velocity.y = enemySpeed / 2;

					case 3:	//Top
						var slot = FlxG.random.int(0, 4) * 32;
						x = frame_small.x + slot;
						y = (frame_small.y + frame_small.height) - enemy.height;
						enemy.velocity.y = enemySpeed;
						enemy.angle = 180;

						if (slot < 4)
							enemy.velocity.x = -enemySpeed / 2;
						else if (slot == 4)
							enemy.velocity.x = 0;
						else
							enemy.velocity.x = enemySpeed / 2;
				}
				enemy.setPosition(x, y);
				enemy.animation.play("walk");
				enemy.revive();
			}

			if (t.loopsLeft == 0) {
				enemyTimer.start(fixedWaveTime + extraWaveTime, spawnEnemyWave);
				numWaves++;
			}
		},numEnemies);
	}
}

	
enum Wall {
	Bottom;
	Left;
	Top;
	Right;
}
