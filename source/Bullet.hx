package;

import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class Bullet extends FlxSprite
{
    private var _speed:Float = 200;
    private var _direction:Int;

    public function new(x:Float, y:Float, direction:Int)
    {
        super(x, y);
        loadGraphic(AssetPaths.bullet__png, false, 8, 8);
        _direction = direction;
        velocity.x = _speed * _direction;
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
    }

    override public function kill():Void
    {
        alive = false;
        FlxTween.tween(this, { alpha: 0, y: y - 16 }, 0.33, { ease: FlxEase.circOut, onComplete: finishKill });
    }

    private function finishKill(_):Void
    {
        exists = false;
    }
 }