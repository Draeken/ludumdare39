package;

import flixel.input.keyboard.FlxKey;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

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

    private var _maxEnergy:Float = 1000;
	private var _energy:Float = 1000;

    private var _shotKeyPressedTime:Float = 0;

    public function new(playState:PlayState, ?x:Float = 0, ?y:Float = 0)
    {
        super(x, y);

        _playState = playState;

        loadGraphic(AssetPaths.player__png, true, 32, 48);
        animation.add("forward", [0, 1, 2, 3, 4], 12, false);

        setFacingFlip(FlxObject.LEFT, false, false);
        setFacingFlip(FlxObject.RIGHT, true, false);

		maxVelocity.set(RUN_SPEED, JUMP_SPEED);
		acceleration.y = GRAVITY;
		drag.x = maxVelocity.x * DRAG_FACTOR;
        _direction = 1;
    }

    public function getEnergy():Float
    {
        return _energy;
    }

	public function addEnergy(v:Float):Void
	{
		_energy = cast Math.min(_energy + v, _maxEnergy);
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
        shoot(elapsed);
        _playState.decreaseEnergy(elapsed * 5);

        super.update(elapsed);
    }

    public function respawn():Void
    {
        x = _initialX;
        y = _initialY;
        _energy = _maxEnergy;
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
            facing = FlxObject.RIGHT;
            animation.play("forward");
		}

		if (FlxG.keys.anyPressed([RIGHT, D]))
		{
            acceleration.x = drag.x;
            _direction = 1;
            facing = FlxObject.LEFT;
            animation.play("forward");
		}

        if (acceleration.x != 0)
            _playState.decreaseEnergy(elapsed * 50);

        jump(elapsed);

        if (isTouching(FlxObject.FLOOR) && !FlxG.keys.anyPressed(_jumpKeys))
        {
            _jumpTime = -1;
            _timesJumped = 0;
        }
    }

    public function decreaseEnergy(value:Float)
    {
        _energy -= value;

        if (_energy <= 0)
         {
            _playState.killPlayer();
            _energy = 0;
         }
    }

    private function jump(elapsed:Float):Void
    {
        if (FlxG.keys.anyJustPressed(_jumpKeys) && (_timesJumped < JUMPS_ALLOWED))
        {
            if (!isTouching(FlxObject.FLOOR))
            {
                var s = new FlxSprite();
                s.loadGraphic(AssetPaths.Shitty_xplozion__png, true, 48, 32);
                s.alpha = 0.5;
                s.centerOrigin();
                s.scale.set(0.5, 0.5);
                s.setPosition(getPosition().x - 9, getGraphicMidpoint().y - 8 + height / 2);
                _playState.add(s);

                FlxTween.tween(s, { alpha: 0, y: s.y + 10 }, 0.25, { ease:FlxEase.cubeInOut, onComplete: function(_)
                {
                    _playState.remove(s);
                }});
            }

            _playState.decreaseEnergy(5);
            
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

    private function shoot(elapsed:Float):Void
    {
        var offset:Float = velocity.x / maxVelocity.x;

        if (_direction == 1)
            offset += width / 2.0;

        if (FlxG.keys.justPressed.X)
        {
            _playState.decreaseEnergy(10);
            
            var offset:Float = velocity.x / maxVelocity.x;

            if (_direction == 1)
                offset += width / 2.0;

            var energyPercent:Float = _energy / _maxEnergy;
            if (energyPercent > 0.75)
                _playState.addBullet(x + _direction * offset, y + (height / 2.0) - 16, _direction);

            if (energyPercent > 0.3)
                _playState.addBullet(x + _direction * offset, y + (height / 2.0) + 16, _direction);

            _playState.addBullet(x + _direction * offset, y + (height / 2.0), _direction);

            FlxG.sound.play(AssetPaths.shoot1__wav);
        }
        else if (FlxG.keys.pressed.X)
        {
            _shotKeyPressedTime += elapsed;
        }
        else if (FlxG.keys.justReleased.X)
        {
            if (_shotKeyPressedTime > 0.3)
            {
                var chargingShotAmount:Float = Math.min(1 + _shotKeyPressedTime * 3, 5);

                _playState.addMegaBullet(x + _direction * offset, y + (height / 2.0), _direction, chargingShotAmount);

                decreaseEnergy(chargingShotAmount * 50);
                FlxG.log.notice("Charging shot amount: " + Std.string(chargingShotAmount * 10));
            }

            _shotKeyPressedTime = 0;
            FlxG.sound.play(AssetPaths.shoot1__wav);
        }
    }
}