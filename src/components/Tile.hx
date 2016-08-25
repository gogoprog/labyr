package components;

import gengine.math.*;
import ash.fsm.*;

enum TileType
{
    EMPTY;
    L;
    I;
    T;
}

class Tile
{
    public var position:IntVector2 = new IntVector2(0, 0);
    public var angle:Float = 0;
    public var sm:EntityStateMachine;
    public var type:TileType;
    public var matching:Bool = false;

    public function new()
    {
    }
}
