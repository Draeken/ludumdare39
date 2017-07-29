package;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.addons.editors.tiled.TiledObject;
import flixel.util.FlxTimer;

class Vec2
{
    public var x:Int;
    public var y:Int;
    public function new(x:Int, y:Int) { this.x = x; this.y = y; }
}

class BatterySpawner extends FlxGroup
{
    private var _player:Player;

    private var _tiles:Array<TiledObject>;
    private var _battery:Battery;

    private var _spawnTimer:FlxTimer;

    public function new(player:Player)
    {
        super();

        _player = player;

        _tiles = new Array<TiledObject>();

        resetSpawnTimer();
    }

    public function addTile(tile:TiledObject):Void
    {
        _tiles.push(tile);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (_battery != null)
            FlxG.overlap(_player, _battery, this.onPlayerBatteryOverlap);
    }

    private function onPlayerBatteryOverlap(player:Player, battery:Battery):Void
    {
        _battery.apply(_player);
    
        despawnBattery();

        resetSpawnTimer();
    }

    private function resetSpawnTimer():Void
    {
        _spawnTimer = new FlxTimer().start(FlxG.random.int(1, 1), spawnBattery);
    }

    private function spawnBattery(timer:FlxTimer):Void
    {
        if (_battery != null)
            return;

        var position:Vec2 = getBatteryPosition();

        FlxG.log.notice("Battery spawned at" + position.x + position.y);

        _battery = new Battery(_player, position.x, position.y);
        this.add(_battery);
    }

    private function despawnBattery():Void
    {
        this.remove(_battery);
        _battery = null;
    }

    private function getBatteryPosition():Vec2
    {
        var tile = FlxG.random.getObject(_tiles);

        var x:Int = FlxG.random.int(tile.x, tile.x + tile.width);
        var y:Int = FlxG.random.int(tile.y, tile.y + tile.height);

        return new Vec2(x, y);
    }
}
