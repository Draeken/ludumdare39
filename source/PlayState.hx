package;

import flixel.FlxState;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxTimer;

class PlayState extends FlxState
{
	private var _map:TiledMap;
	private var _mWalls:FlxTilemap;
	private var _player:Player;
	private var _grpEnemySpawners:FlxTypedGroup<EnemySpawner>;

	private var _enemies:FlxTypedGroup<Enemy>;

	private var _playerReviveTimer:FlxTimer;

	private var _bullets:FlxTypedGroup<Bullet>;

	override public function create():Void
	{
		_map = new TiledMap(AssetPaths.level0__tmx);
		_mWalls = new FlxTilemap();
		_mWalls.loadMapFromArray(cast(_map.getLayer("Walls"), TiledTileLayer).tileArray, _map.width,
			_map.height, AssetPaths.tiles__png, _map.tileWidth, _map.tileHeight,
			FlxTilemapAutoTiling.OFF, 1, 1, 3);
		_mWalls.follow();
		_mWalls.setTileProperties(2, FlxObject.NONE);
		_mWalls.setTileProperties(3, FlxObject.ANY);

		add(_mWalls);

		_enemies =  new FlxTypedGroup<Enemy>();
		add(_enemies);

		_grpEnemySpawners = new FlxTypedGroup<EnemySpawner>();
		add(_grpEnemySpawners);

		_player = new Player(this);
		_playerReviveTimer = new FlxTimer();

		_bullets = new FlxTypedGroup<Bullet>();
		add(_bullets);

		// Parse map
		var tmpMapSpawn:TiledObjectLayer = cast _map.getLayer("Player");
		var tmpMapEnemySpawners:TiledObjectLayer = cast _map.getLayer("MobSpawners");

		for (e in tmpMapSpawn.objects) { placeSpawn(e);	}
		for (e in tmpMapEnemySpawners.objects) { placeEnemySpawners(e); }

		add(_player);

		FlxG.camera.follow(_player, FlxCameraFollowStyle.PLATFORMER, 1);

		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		FlxG.collide(_player, _mWalls);

		for (enemy in _enemies)
		{
			FlxG.collide(enemy, _mWalls, onEnemyCollideWall);
			FlxG.overlap(_player, enemy, onPlayerTouchEnemy);
			FlxG.overlap(enemy, _bullets, onEnemyTouchBullet);
		}
	}

	private function placeSpawn(e: TiledObject):Void
	{
		_player.setInitialPosition(e.x, e.y);
	}

	private function placeEnemySpawners(e:TiledObject):Void
	{
		_grpEnemySpawners.add(new EnemySpawner(this, e.x, e.y));
	}

	private function onPlayerTouchEnemy(player:Player, enemy:Enemy):Void
	{
		if (!player.alive || !player.exists || !enemy.alive || !enemy.exists) { return; }

		FlxObject.updateTouchingFlags(player, enemy);

		if ((player.justTouched(FlxObject.WALL) && enemy.justTouched(FlxObject.WALL)) ||
			(player.justTouched(FlxObject.UP) && enemy.justTouched(FlxObject.FLOOR)))
		{
			player.kill();
			FlxG.camera.shake(.02, 0.5);
			_playerReviveTimer.start(3, playerRespawn, 1);
		}
		else if (player.justTouched(FlxObject.DOWN) && enemy.justTouched(FlxObject.UP))
		{
			player.velocity.y = -100;
			enemy.kill();
		}
	}

	private function onEnemyTouchBullet(enemy:Enemy, bullet:Bullet):Void
	{
		enemy.kill();
		bullet.kill();
	}

	private function playerRespawn(timer:FlxTimer):Void
	{
		_player.respawn();
	}

	private function onEnemyCollideWall(enemy:Enemy, wall:FlxObject):Void
	{
		if (enemy.justTouched(FlxObject.WALL))
			enemy.switchDirection();
	}

	public function addEnemy(x:Float, y:Float):Void
	{
		_enemies.add(new Enemy(x, y));
	}

	public function addBullet(x:Float, y:Float, direction:Int):Void
	{
		_bullets.add(new Bullet(x, y, direction));
	}
}