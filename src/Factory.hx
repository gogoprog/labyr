import gengine.*;
import gengine.components.*;
import ash.systems.*;
import ash.fsm.*;
import components.*;
import gengine.math.*;
import components.Tile.TileType;

class Factory
{
    static private var pool:Array<Entity> = new Array<Entity>();

    static public function init()
    {
        for(i in 0...(GridConfig.width * GridConfig.height) * 2 )
        {
            pool.push(createItem());
        }
    }

    static public function onItemRemoved(e:Entity)
    {
        pool.push(e);
    }

    static public function createItem():Entity
    {
        var e = new Entity();
        var sm = new EntityStateMachine(e);

        e.add(new Tile());
        e.add(new StaticSprite2D());

        var hs = GridConfig.tileSize / 2;

        e.get(StaticSprite2D).setLayer(0);
        e.get(StaticSprite2D).setDrawRect(new Rect(new Vector2(-hs, -hs), new Vector2(hs, hs)));
        e.get(Tile).sm = sm;

        sm.createState("idle");
        sm.changeState("idle");

        sm.createState("moving")
            .add(TileMovement).withInstance(new TileMovement());

        sm.createState("disappearing")
            .add(TileDisappearing).withInstance(new TileDisappearing());

        return e;
    }

    static public function getItem(type:Int, angle:Float)
    {
        var e:Entity;

        if(pool.length > 0)
        {
            e = pool.shift();
        }
        else
        {
            e = createItem();
        }

        var ttype = TileType.createByIndex(type);

        var textureName:String;

        switch (ttype) {
        case EMPTY:
            textureName = "tile0.png";
        case L:
            textureName = "tile2.png";
        case I:
            textureName = "tile1.png";
        case T:
            textureName = "tilet.png";
        }

        e.get(StaticSprite2D).setColor(new Color(1, 1, 1, 1));
        e.get(StaticSprite2D).setSprite(Gengine.getResourceCache().getSprite2D(textureName, true));
        e.get(Tile).type = ttype;
        e.get(Tile).angle = angle;
        e.get(Tile).matching = false;

        e.setRotation2D(angle);

        return e;
    }

    static public function createBorder(size:IntVector2)
    {
        var e = new Entity();
        e.add(new StaticSprite2D());
        e.get(StaticSprite2D).setDrawRect(new Rect(new Vector2(-size.x/2, -size.y/2), new Vector2(size.x/2, size.y/2)));
        e.get(StaticSprite2D).setTextureRect(new Rect(new Vector2(0, 0), new Vector2(size.x/256, size.y/256)));
        var sprite = Gengine.getResourceCache().getSprite2D("ground.png", true);
        sprite.getTexture().setAddressMode(0, 1);
        sprite.getTexture().setAddressMode(1, 1);
        e.get(StaticSprite2D).setSprite(sprite);
        e.get(StaticSprite2D).setLayer(10);
        return e;
    }
}
