package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxObject;

class Player extends FlxSprite
{
    private var _playState:PlayState;
    private var _initialX:Float;
    private var _initialY:Float;
    private var _direction:Int;

    public function new(playState:PlayState, ?x:Float = 0, ?y:Float = 0)
    {
        super(x, y);

        _playState = playState;

        loadGraphic(AssetPaths.player__png, false);

        setFacingFlip(FlxObject.LEFT, false, false);
        setFacingFlip(FlxObject.RIGHT, true, false);

        setSize(24, 15);
		maxVelocity.set(150, 300);
		acceleration.y = 800;
		drag.x = maxVelocity.x * 4;
        _direction = 1;
    }

    public function setInitialPosition(X:Float, Y:Float):Void
    {
        _initialX = X;
        _initialY = Y;

        x = _initialX;
        y = _initialY;
    }

    override public function update(elapsed:Float):Void
    {
        movement();
        shoot();
        super.update(elapsed);
    }

    public function respawn():Void
    {
        x = _initialX;
        y = _initialY;
        revive();
    }

    private function movement():Void
    {
        acceleration.x = 0;

		if (FlxG.keys.anyPressed([LEFT, A]))
		{
			velocity.x = -maxVelocity.x;
            _direction = -1;
		}

		if (FlxG.keys.anyPressed([RIGHT, D]))
		{
			velocity.x = maxVelocity.x;
            _direction = 1;
		}

		if (FlxG.keys.anyJustPressed([SPACE, UP, W]) && isTouching(FlxObject.FLOOR))
		{
			velocity.y = -maxVelocity.y;
            FlxG.sound.play(AssetPaths.jump__wav);
		}
    }

    private function shoot():Void
    {
        if (FlxG.keys.justPressed.CONTROL)
        {
            _playState.addBullet(x + (width / 2.0), y + (height / 2.0), _direction);
            FlxG.sound.play(AssetPaths.shoot1__wav);
        }
    }
}