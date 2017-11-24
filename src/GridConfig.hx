import gengine.math.*;

class GridConfig
{
    static public var width:Int = 8;
    static public var height:Int = 8;
    static public var tileSize:Int = 64;
    static public var offset = new Vector2(-width/2 * tileSize + tileSize*2, -height/2 * tileSize + tileSize/2);
}
