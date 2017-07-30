package;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

using flixel.util.FlxSpriteUtil;
using flixel.math.FlxPoint;

class HUD extends FlxTypedGroup<FlxSprite>
{
    private var _batteryContainerSprite:FlxSprite;
    private var _batteryContentSprite:FlxSprite;
    private var _batteryEnergyText:FlxText;

    private var _batteryMaxEnergyValue:Int;

    private var _batteryContentInitialHeight:Int;

    private var _lastEnergy:Float;
    private var _actualBatteryContentSpriteScaleY:Float;
    private var _batteryContentTween:FlxTween;

    private var _scoreText:FlxText;
    private var _shaking:Bool;
    private var _shakeIntensity:Float;
    private var _shakeDuration:Float;

    private var _batteryInitialPosition:FlxPoint;

    public function new()
    {
        super();

        _batteryContentInitialHeight = 100;
        _batteryMaxEnergyValue = 1000;

        _batteryInitialPosition = new FlxPoint(20, _batteryContentInitialHeight);

        _batteryContentSprite = new FlxSprite().makeGraphic(cast(_batteryInitialPosition.x, Int), cast(_batteryInitialPosition.y, Int), FlxColor.YELLOW);
        _batteryContentSprite.x = FlxG.width - 50;
        _batteryContentSprite.y = 20;
        _batteryContentSprite.origin.set(_batteryContentSprite.width / 2, _batteryContentSprite.height);
        _actualBatteryContentSpriteScaleY = 1;

        _batteryEnergyText = new FlxText(FlxG.width - 50, 5, 0, "", 8);
        _batteryEnergyText.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);

        add(_batteryContentSprite);
        add(_batteryEnergyText);

        _scoreText = new FlxText(FlxG.width / 2, 50, 0, "Score 0", 16);
        _scoreText.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);

        add(_scoreText);

        // The UI sprites will stays at their position on the screen
        // even if the camera moves
        forEach(function(spr:FlxSprite)
        {
            spr.scrollFactor.set(0, 0);
        });
    }
    public function setScore(score:Int):Void
    {
        _scoreText.text = "Score " + Std.string(score);
        _scoreText.setPosition(FlxG.width / 2 - _scoreText.width / 2, 50);
    }

    override public function update(elapsed:Float):Void
    {
        if (_shaking)
        {
            if (_shakeDuration > 0)
            {
                _shakeDuration -= elapsed;
                _batteryContentSprite.x = _batteryInitialPosition.x + (FlxG.random.float(1, 5) * _shakeIntensity);
                _batteryContentSprite.y = _batteryInitialPosition.y + (FlxG.random.float(1, 5) * _shakeIntensity);
            }
            else
            {
                _shaking = false;
                _shakeDuration = 0;
                _batteryContentSprite.x = _batteryInitialPosition.x;
                _batteryContentSprite.y = _batteryInitialPosition.y;
            }
        }

        super.update(elapsed);
    }

    public function setEnergy(energy:Float = 0):Void
    {
        var percent = energy / _batteryMaxEnergyValue;
        
        if (_lastEnergy > energy && (_lastEnergy - energy) > 5)
        {
            _batteryContentTween = FlxTween.tween(_batteryContentSprite.scale, { y: percent }, 0.5, { ease: FlxEase.bounceOut, onComplete: batteryAnimationFinished });
        }
        else
        {
            if (_batteryContentTween == null || (_batteryContentTween != null && _batteryContentTween.finished))
                _batteryContentSprite.scale.y = percent;
        }

        _actualBatteryContentSpriteScaleY = percent;

        _batteryEnergyText.text = Std.string(cast(Math.ceil(percent * 100), Int)) + "%";
        
        if (percent > 0.75)
            _batteryContentSprite.color = 0x1D773E;
        else if (percent > 0.3)
            _batteryContentSprite.color = 0xFF6A00;
        else
            _batteryContentSprite.color = 0xFF0000;

        _lastEnergy = energy;
    }

    private function batteryAnimationFinished(_):Void
    {
        _batteryContentSprite.scale.y = _actualBatteryContentSpriteScaleY;
    }

    public function shakeBattery(Intensity:Float, Duration:Float)
    {
        // _shaking = true;
        // _shakeIntensity = Intensity;
        // _shakeDuration = Duration * 1000; // ms
    }
}