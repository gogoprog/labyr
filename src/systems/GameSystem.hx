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
            Application.changeState("menu");
        }
    }

    private function newGrid()
    {
        var offset = GridConfig.offset;
        for(i in 0...GridConfig.width)
        {
            for(j in 0...GridConfig.height)
            {
                var e:Entity;
                if(Math.random() > 0.8)
                {
                    e = Factory.getItem(Type.enumIndex(TileType.POWERUP), 0, Std.random(4));
                }
                else
                {
                    e = Factory.getItem(Std.random(3) + 1, Std.random(4) * 90 );
                }
                e.get(Tile).sm.changeState("moving");
                e.get(Tile).position = new IntVector2(i, j);
                e.get(TileMovement).from = new Vector2(offset.x + i * GridConfig.tileSize, offset.y + j * GridConfig.tileSize + 10 * GridConfig.tileSize);
                e.get(TileMovement).to = new Vector2(offset.x + i * GridConfig.tileSize, offset.y + j * GridConfig.tileSize);
                e.get(TileMovement).duration = 0.1;
                e.get(TileMovement).fromAngle = e.get(Tile).angle - 90;
                e.get(TileMovement).toAngle = e.get(Tile).angle;
                engine.addEntity(e);
            }
        }
    }
}
