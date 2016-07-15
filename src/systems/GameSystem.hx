package systems;

import gengine.*;
import gengine.components.*;
import ash.systems.*;
import ash.fsm.*;
import components.*;
import gengine.math.*;
import components.Tile.TileType;


class GameSystem extends System
{
    private var engine:Engine;

    public function new()
    {
        super();
    }

    override public function addToEngine(_engine:Engine)
    {
        engine = _engine;
        newGrid();
    }

    override public function update(dt:Float):Void
    {
        var input = Gengine.getInput();

        if(input.getScancodePress(41))
        {
            Application.esm.changeState("menu");
        }
    }

    private function createItem(type:Int, angle:Float)
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

        return e;
    }

    private function newGrid()
    {
        var offset = GridConfig.offset;

        for(i in 0...GridConfig.width)
        {
            for(j in 0...GridConfig.height)
            {
                var e = createItem(Std.random(3), Std.random(4) * 90);
                engine.addEntity(e);

                e.get(Tile).sm.changeState("moving");
                e.get(Tile).position = new IntVector2(i, j);
                e.get(TileMovement).from = new Vector2(offset.x + i * GridConfig.tileSize, offset.y + j * GridConfig.tileSize + 10 * GridConfig.tileSize);
                e.get(TileMovement).to = new Vector2(offset.x + i * GridConfig.tileSize, offset.y + j * GridConfig.tileSize);
                e.get(TileMovement).duration = 1;
                e.get(TileMovement).fromAngle = e.get(Tile).angle - 90;
                e.get(TileMovement).toAngle = e.get(Tile).angle;
            }
        }
    }
}
