package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class Battery extends FlxSprite
{
    public function new(player:Player, ?x:Float = 0, ?y:Float = 0)
    {
        super(x, y);

        loadGraphic(AssetPaths.battery__png, false, 16, 8);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
    }

    public function apply(player:Player):Void
    {
        // FIXME
    }
}
