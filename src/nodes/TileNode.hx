package nodes;

import gengine.components.*;
import gengine.*;
import components.*;
import gengine.math.Color;

class TileNode extends Node<TileNode>
{
    public var tile:Tile;
    public var sprite:StaticSprite2D;

    public function disappear()
    {
        sprite.setColor(new Color(1.0,0.0,1.0,1.0));
        tile.sm.changeState("disappearing");
        tile.matching = true;
    }
}
