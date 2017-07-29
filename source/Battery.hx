package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

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

        FlxG.overlap(_player, this, this.onPlayerOverlap);
    }

    public function apply(player:Player):Void
    {
        _playState.addEnergy(200);
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
