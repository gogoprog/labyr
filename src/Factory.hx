import gengine.*;
import gengine.components.*;
import ash.systems.*;
import ash.fsm.*;
import components.*;
import gengine.math.*;
import components.Tile.TileType;
import components.Tile.Powerup;
import config.GridConfig;

class Factory
{
    static private var pool:Array<Entity> = new Array<Entity>();

    static public function init()
    {
        for(i in 0...(GridConfig.width * GridConfig.height) * 2)
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

        e.get(StaticSprite2D).setUseDrawRect(true);
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

    static public function getItem(type:Int, angle:Float, ?powerup)
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
        switch(ttype)
        {
            case EMPTY:
                textureName = "tile0.png";
            case L:
                textureName = "tile2.png";
            case I:
                textureName = "tile1.png";
            case T:
                textureName = "tilet.png";
            case POWERUP:
                var powerupv = Powerup.createByIndex(powerup);
                e.get(Tile).powerup = powerupv;
                switch(powerupv)
                {
                    case HBOMB:
                        textureName = "lock0.png";
                    case VBOMB:
                        textureName = "lock1.png";
                    case XBOMB:
                        textureName = "lock2.png";
                    case ABOMB:
                        textureName = "lock3.png";
                }
        }
        e.get(StaticSprite2D).setSprite(Gengine.getResourceCache().getSprite2D(textureName, true));
            e.get(StaticSprite2D).setColor(new Color(1, 1, 1, 1));
        e.get(Tile).type = ttype;
        e.get(Tile).angle = angle;
        e.get(Tile).matching = false;
        e.setRotation2D(angle);
        if(powerup == null)
        {
            e.get(Tile).powerup = null;
        }
        return e;
    }

    static public function createBorder(size:IntVector2)
    {
        var e = new Entity();
        e.add(new StaticSprite2D());
        var sprite = Gengine.getResourceCache().getSprite2D("new_ground.jpg", true);
        e.get(StaticSprite2D).setSprite(sprite);
        e.get(StaticSprite2D).setLayer(-1);
        return e;
    }
}
