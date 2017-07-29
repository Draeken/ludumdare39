package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;

class EnemySpawner extends FlxSprite
{
    private var _playState:PlayState;
    private var _spawnTimer:FlxTimer;

    public function new(playState:PlayState, ?x:Float = 0, ?y:Float = 0)
    {
        super(x, y) ;
        _playState = playState;
        visible = false;
        _spawnTimer = new FlxTimer().start(FlxG.random.int(1, 5), spawnEnemy);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
    }

    private function spawnEnemy(timer:FlxTimer):Void
    {
        timer.reset(FlxG.random.int(10, 50));
        _playState.addEnemy(this.x, this.y);
    }
}