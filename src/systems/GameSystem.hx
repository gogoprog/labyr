package systems;

import gengine.*;
import gengine.components.*;
import ash.systems.*;
import ash.fsm.*;
import components.*;
import gengine.math.*;

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

    private function createItem()
    {
        var e = new Entity();
        var sm = new EntityStateMachine(e);

        e.add(new Tile());
        e.add(new StaticSprite2D());
        e.get(StaticSprite2D).setSprite(Gengine.getResourceCache().getSprite2D("tile0.png", true));

        e.get(Tile).sm = sm;

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
                var e = createItem();
                engine.addEntity(e);

                e.get(Tile).sm.changeState("moving");
                e.get(Tile).position = new IntVector2(i, j);
                e.get(TileMovement).from = new Vector2(offset.x + i * GridConfig.tileSize, offset.y + j * GridConfig.tileSize + 10 * GridConfig.tileSize);
                e.get(TileMovement).to =  new Vector2(offset.x + i * GridConfig.tileSize, offset.y + j * GridConfig.tileSize);
                e.get(TileMovement).duration = 1;
                e.get(TileMovement).time = 0;
                e.get(TileMovement).fromAngle = 0;
                e.get(TileMovement).toAngle = 180;
            }
        }
    }
}
