package;

import flixel.input.keyboard.FlxKey;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxObject;

class Player extends FlxSprite
{
    private static inline var RUN_SPEED:Int = 500;
    private static inline var JUMP_SPEED:Int = 666;
    private static inline var JUMPS_ALLOWED:Int = 2;
    private static inline var JUMP_FACTOR:Float = 0.6;
    private static inline var GRAVITY:Int = 2222;
    private static inline var DRAG_FACTOR:Int = 8;


    private var _playState:PlayState;
    private var _initialX:Float;
    private var _initialY:Float;
    private var _direction:Int;

	private var _jumpTime:Float = -1;
	private var _timesJumped:Int = 0;
    private var _jumpKeys:Array<FlxKey> = [SPACE, UP, W];
    private var _jumpPower:Float = 0.25;

    public function new(playState:PlayState, ?x:Float = 0, ?y:Float = 0)
    {
        super(x, y);

        _playState = playState;

        loadGraphic(AssetPaths.player__png, false);

        setFacingFlip(FlxObject.LEFT, false, false);
        setFacingFlip(FlxObject.RIGHT, true, false);

		maxVelocity.set(RUN_SPEED, JUMP_SPEED);
		acceleration.y = GRAVITY;
		drag.x = maxVelocity.x * DRAG_FACTOR;
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
        movement(elapsed);
        shoot();
        super.update(elapsed);
    }

    public function respawn():Void
    {
        x = _initialX;
        y = _initialY;
        revive();
    }

    private function movement(elapsed:Float):Void
    {
        acceleration.x = 0;
        acceleration.y = GRAVITY;

		if (FlxG.keys.anyPressed([LEFT, A]))
		{
            acceleration.x = -drag.x;
            _direction = -1;
		}

		if (FlxG.keys.anyPressed([RIGHT, D]))
		{
            acceleration.x = drag.x;
            _direction = 1;
		}

        jump(elapsed);

        if (isTouching(FlxObject.FLOOR) && !FlxG.keys.anyPressed(_jumpKeys))
        {
            _jumpTime = -1;
            _timesJumped = 0;
        }
    }

    private function jump(elapsed:Float):Void
    {
        if (FlxG.keys.anyJustPressed(_jumpKeys) && (_timesJumped < JUMPS_ALLOWED))
        {
            FlxG.sound.play(AssetPaths.jump__wav);
            _timesJumped++;
            _jumpTime = 0;
        }
        if (FlxG.keys.anyPressed(_jumpKeys) && (_jumpTime >= 0))
        {
            _jumpTime += elapsed;

            if (_jumpTime > _jumpPower)
            {
                _jumpTime = -1;
            }
            else
            {
                velocity.y = -JUMP_FACTOR * maxVelocity.y;
            }

        }
        else
        {
            _jumpTime = -1;
        }
    }

    private function shoot():Void
    {
        if (FlxG.keys.justPressed.X)
        {
            var offset:Float = velocity.x / maxVelocity.x;
            _playState.addBullet(x + _direction * ((width / 2.0) + offset), y + (height / 2.0), _direction);
            FlxG.sound.play(AssetPaths.shoot1__wav);
        }
    }
}