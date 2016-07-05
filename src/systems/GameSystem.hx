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
            Application.esm.changeState("Menu");
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

        e.get(Tile).sm.changeState("moving");
        e.get(TileMovement).from = new Vector2(0, 0);
        e.get(TileMovement).to = new Vector2(Math.random() * 256, Math.random() * 256);

        return e;
    }

    private function newGrid()
    {
        for(i in 0...10)
        {
            for(j in 0...10)
            {
                var e = createItem();
                engine.addEntity(e);
            }
        }
    }
}
