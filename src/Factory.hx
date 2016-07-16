import gengine.*;
import gengine.components.*;
import ash.systems.*;
import ash.fsm.*;
import components.*;
import gengine.math.*;
import components.Tile.TileType;

class Factory
{
    static public function createItem(type:Int, angle:Float)
    {
        var e = new Entity();
        var sm = new EntityStateMachine(e);
        var ttype = TileType.createByIndex(type);

        e.add(new Tile());
        e.add(new StaticSprite2D());

        var textureName:String;

        switch (ttype) {
        case EMPTY:
            textureName = "tile0.png";
        case L:
            textureName = "tile2.png";
        case I:
            textureName = "tile1.png";
        }

        var hs = GridConfig.tileSize / 2;

        e.get(StaticSprite2D).setSprite(Gengine.getResourceCache().getSprite2D(textureName, true));
        e.get(StaticSprite2D).setDrawRect(new Rect(new Vector2(-hs, -hs), new Vector2(hs, hs)));

        e.get(Tile).sm = sm;
        e.get(Tile).type = ttype;
        e.get(Tile).angle = angle;

        e.setRotation2D(angle);

        sm.createState("idle");

        sm.createState("moving")
            .add(TileMovement).withInstance(new TileMovement());

        sm.createState("disappearing")
            .add(TileDisappearing).withInstance(new TileDisappearing());

        return e;
    }

}
