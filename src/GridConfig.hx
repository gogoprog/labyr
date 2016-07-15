import gengine.math.*;

class GridConfig
{
    static public var width:Int = 20;
    static public var height:Int = 20;
    static public var tileSize:Int = Std.int(640 / width);
    static public var offset = new Vector2(-width/2 * tileSize + tileSize/2, -height/2 * tileSize + tileSize/2);
}
