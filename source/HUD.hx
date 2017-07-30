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
    private var _batteryFlashSprite:FlxSprite;

    private var _batteryMaxEnergyValue:Int;
    private var _batteryContentInitialHeight:Int;

    private var _lastEnergy:Float;
    private var _actualBatteryContentSpriteScaleY:Float;
    private var _batteryContentTween:FlxTween;

    private var _scoreText:FlxText;
    private var _gameOverText:FlxText;
    private var _gameOverReasonText:FlxText;
    private var _gameOverRetryText:FlxText;
    private var _gameOverScoreText:FlxText;
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

        _batteryFlashSprite = new FlxSprite().makeGraphic(cast(_batteryInitialPosition.x, Int), cast(_batteryInitialPosition.y, Int), FlxColor.WHITE);
        _batteryFlashSprite.x = FlxG.width - 50;
        _batteryFlashSprite.y = 20;
        _batteryFlashSprite.origin.set(_batteryFlashSprite.width / 2, _batteryFlashSprite.height);

        _batteryEnergyText = new FlxText(FlxG.width - 50, 5, 0, "", 8);
        _batteryEnergyText.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);

        add(_batteryContentSprite);
        add(_batteryEnergyText);
        add(_batteryFlashSprite);
        _batteryFlashSprite.visible = false;

        _scoreText = new FlxText(FlxG.width / 2, 50, 0, "Score 0", 16);
        _scoreText.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);
        add(_scoreText);

        _gameOverText = new FlxText(FlxG.width / 2, FlxG.height / 2, 0, "GAME OVER", 128);
        _gameOverText.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);
        _gameOverText.screenCenter();
        _gameOverText.y -= 64;

        _gameOverReasonText = new FlxText(FlxG.width / 2, FlxG.height / 2, 0, "Running out of energy", 32);
        _gameOverReasonText.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);
        _gameOverReasonText.screenCenter();
        _gameOverReasonText.y += 32;

        _gameOverRetryText = new FlxText(FlxG.width / 2, FlxG.height / 2, 0, "Press the shoot key to retry", 16);
        _gameOverRetryText.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);
        _gameOverRetryText.screenCenter();
        _gameOverRetryText.y += 96;

        _gameOverScoreText = new FlxText(FlxG.width / 2, FlxG.height / 2, 0, "Score 0", 64);
        _gameOverScoreText.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);

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
                var xOffset = FlxG.random.float(1, 5);
                var yOffset = FlxG.random.float(1, 5);
                _batteryContentSprite.x = _batteryInitialPosition.x + (xOffset * _shakeIntensity);
                _batteryContentSprite.y = _batteryInitialPosition.y + (yOffset * _shakeIntensity);
                _batteryFlashSprite.x = _batteryInitialPosition.x + (xOffset * _shakeIntensity);
                _batteryFlashSprite.y = _batteryInitialPosition.y + (yOffset * _shakeIntensity);
            }
            else
            {
                _shaking = false;
                _shakeDuration = 0;
                _batteryContentSprite.x = _batteryInitialPosition.x;
                _batteryContentSprite.y = _batteryInitialPosition.y;
                _batteryFlashSprite.x = _batteryInitialPosition.x;
                _batteryFlashSprite.y = _batteryInitialPosition.y;
            }
        }

        super.update(elapsed);
    }

    public function setEnergy(energy:Float = 0):Void
    {
        var percent = energy / _batteryMaxEnergyValue;

        if (_lastEnergy > energy && (_lastEnergy - energy) >= 10)
        {
            _batteryFlashSprite.visible = true;
            _batteryFlashSprite.alpha = 0;
            FlxTween.tween(_batteryFlashSprite, { alpha: 1 }, 0.25, { ease: FlxEase.cubeInOut, onComplete: flashAnimationComplete });
        }

        _batteryContentSprite.scale.y = percent;
        _batteryFlashSprite.scale.y = percent;
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

    private function flashAnimationComplete(_):Void
    {
        _batteryFlashSprite.visible = false;
    }

    public function shakeBattery(Intensity:Float, Duration:Float)
    {
        // _shaking = true;
        // _shakeIntensity = Intensity;
        // _shakeDuration = Duration * 1000; // ms
    }

    public function gameOver(value:Bool, reason:String)
    {
        _gameOverReasonText.text = reason;
        _gameOverScoreText.text = _scoreText.text;
        _gameOverScoreText.screenCenter();
        _gameOverScoreText.y += 250;

        if (value)
        {
            add(_gameOverText);
            add(_gameOverReasonText);
            add(_gameOverRetryText);
            add(_gameOverScoreText);
        }
        else
        {
            remove(_gameOverText);
            remove(_gameOverReasonText);
            remove(_gameOverRetryText);
            remove(_gameOverScoreText);
        }
    }
}