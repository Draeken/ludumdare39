package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.math.FlxVelocity;
import flixel.math.FlxMath;

class Battery extends FlxSprite
{
    private var _playState:PlayState;
    private var _player:Player;

    private var _killedCallback:Dynamic->Void;

    public function new(playState:PlayState, player:Player, ?x:Float = 0, ?y:Float = 0)
    {
        super(x, y);

        _playState = playState;
        _player = player;

        loadGraphic(AssetPaths.battery__png, false);

        origin.y = height;
        setPosition(x, y - height);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        followPlayer();

        FlxG.overlap(_player, this, this.onPlayerOverlap);
    }

    public function followPlayer()
    {
        if (FlxMath.distanceBetween(this, _player) < 100)
        {
            var playerPosition = _player.getPosition();
            playerPosition.x += _player.origin.x;
            playerPosition.y += _player.origin.y;

            FlxVelocity.moveTowardsPoint(this, playerPosition, Std.int(100));
        }
        else
        {
            velocity.x = 0;
            velocity.y = 0;
        }
    }

    public function apply(player:Player):Void
    {
        _playState.addEnergy(200);
        _playState.addScore(1000);
    }

    private function onPlayerOverlap(player:Player, battery:Battery):Void
    {
        apply(player);

        if (_killedCallback != null)
            _killedCallback(this);
    }

    public function killed(callback:Dynamic->Void)
    {
        _killedCallback = callback;
    }
}
