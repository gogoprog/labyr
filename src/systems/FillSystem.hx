package systems;

import gengine.*;
import gengine.components.*;
import ash.systems.*;
import ash.fsm.*;
import components.*;
import nodes.*;
import gengine.math.*;
import haxe.ds.Vector;
import components.Tile.TileType;
import ash.tools.ListIteratingSystem;
import pathfinder.*;

class FillSystem extends System
{
    private var engine:Engine;
    private var grid:Vector<Vector<TileNode>>;

    public function new()
    {
        super();
        grid = new Vector<Vector<TileNode>>(GridConfig.width);
        for(i in 0...GridConfig.width)
        {
            grid[i] = new Vector<TileNode>(GridConfig.height);
        }
    }

    override public function addToEngine(_engine:Engine)
    {
        super.addToEngine(_engine);
        engine = _engine;
        for(i in 0...GridConfig.width)
        {
            for(j in 0...GridConfig.height)
            {
                grid[i][j] = null;
            }
        }
        var list = engine.getNodeList(TileNode);
        for(node in list)
        {
            var p = node.tile.position;
            grid[p.x][p.y] = node;
        }
        fill();
    }

    override public function removeFromEngine(_engine:Engine)
    {
        super.removeFromEngine(_engine);
    }

    override public function update(dt:Float)
    {
        super.update(dt);
    }

    private function fill()
    {
        var timePerHole = 0.1;
        var offset = GridConfig.offset;
        for(i in 0...GridConfig.width)
        {
            var holes = 0;
            for(j in 0...GridConfig.height)
            {
                if(grid[i][j] == null)
                {
                    holes++;
                }
                else if(holes > 0)
                {
                    var e = grid[i][j].entity;
                    e.get(Tile).sm.changeState("moving");
                    e.get(Tile).position = new IntVector2(i, j - holes);
                    e.get(TileMovement).from = new Vector2(offset.x + i * GridConfig.tileSize, offset.y + (j) * GridConfig.tileSize);
                    e.get(TileMovement).to = new Vector2(offset.x + i * GridConfig.tileSize, offset.y + (j - holes) * GridConfig.tileSize);
                    e.get(TileMovement).duration = timePerHole * (holes);
                    e.get(TileMovement).fromAngle = e.get(Tile).angle;
                    e.get(TileMovement).toAngle = e.get(Tile).angle;
                    grid[i][j - holes] = grid[i][j];
                }
            }
            for(h in 0...holes)
            {
                var dropOffset = 5;
                var e:Entity;
                if(Math.random() > 0.8)
                {
                    e = Factory.getItem(Type.enumIndex(TileType.POWERUP), 0, Std.random(4));
                }
                else
                {
                    e = Factory.getItem(Std.random(3) + 1, Std.random(4) * 90);
                }
                e.get(Tile).sm.changeState("moving");
                e.get(Tile).position = new IntVector2(i, GridConfig.height - holes + h);
                e.get(TileMovement).from = new Vector2(offset.x + i * GridConfig.tileSize, offset.y + (GridConfig.height + dropOffset + h) * GridConfig.tileSize);
                e.get(TileMovement).to = new Vector2(offset.x + i * GridConfig.tileSize, offset.y + (GridConfig.height - holes + h) * GridConfig.tileSize);
                e.get(TileMovement).duration = timePerHole * (holes + dropOffset);
                e.get(TileMovement).fromAngle = e.get(Tile).angle;
                e.get(TileMovement).toAngle = e.get(Tile).angle;
                e.position = new Vector3(offset.x + i * GridConfig.tileSize, offset.y + (GridConfig.height + dropOffset + h) * GridConfig.tileSize, 0);
                engine.addEntity(e);
                var tn = engine.getNodeList(TileNode).tail;
                grid[tn.tile.position.x][tn.tile.position.y] = tn;
            }
        }
    }
}
