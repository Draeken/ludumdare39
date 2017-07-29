package;

import flixel.FlxSprite;

class Teleporter extends FlxSprite
{
    public var type:String;

    public function new(type:String, ?x:Float = 0, ?y:Float = 0, ?width:Float = 0, ?heigth:Float = 0)
    {
        super(x, y);
        this.type = type;
        visible = false;

        setSize(width, heigth);
    }
 }