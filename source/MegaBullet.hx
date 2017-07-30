package;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.math.FlxPoint;

class MegaBullet extends FlxSprite
{
    private var _speed:Float = 750;
    private var _direction:Int;

    public function new(x:Float, y:Float, direction:Int, scale:Float = 1)
    {
        super(x, y);
        loadGraphic(AssetPaths.bulletsheet__png, true, 8, 8);
        setFacingFlip(FlxObject.LEFT, true, false);
        setFacingFlip(FlxObject.RIGHT, false, false);
        this.facing = direction > 0 ? FlxObject.RIGHT : FlxObject.LEFT;
        animation.add("forward", [0, 1, 2, 3, 4], 20, true);
        _direction = direction;
        velocity.x = _speed * _direction;
        this.scale = new FlxPoint(scale, scale);
        centerOrigin();
        centerOffsets();
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        animation.play("forward");
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