package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class Enemy extends FlxSprite
{
    private static inline var GRAVITY:Int = 2000;
    private var _speed:Float;
    private var _direction:Int;

    public function new(?x:Float = 0, ?y:Float = 0)
    {
        super(x, y);
        loadGraphic(AssetPaths.enemy1__png, false);
        setFacingFlip(FlxObject.LEFT, false, false);
        setFacingFlip(FlxObject.RIGHT, true, false);

        _speed = 250;
		acceleration.y = GRAVITY;
        _direction = 1;
        velocity.x = _speed * _direction;
        origin.y = height;
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
    }

    public function switchDirection():Void
    {
        _direction *= -1;
        velocity.x = _speed * _direction;
    }

    public function resetTest():Void
    {
        velocity.x = _speed * _direction;
    }

    override public function kill():Void
    {
        alive = false;
        velocity.x = 0;

        // Shooting dead
        // FlxTween.tween(this.scale, { x: 1.5, y: 0.1 }, 0.25, { ease: FlxEase.bounceInOut, onComplete: finishKill });
        FlxTween.tween(this.scale, { x: 1.5, y: 0.1 }, 0.5, { ease: FlxEase.bounceOut, onComplete: finishKill });

        var hitSounds =
        [
            AssetPaths.hit1__wav,
            AssetPaths.hit2__wav
        ];

        FlxG.sound.play(FlxG.random.getObject(hitSounds));
    }

    private function finishKill(_):Void
    {
        exists = false;
    }
}