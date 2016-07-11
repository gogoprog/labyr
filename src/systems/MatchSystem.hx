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

class MatchSystem extends System
{
    private var engine:Engine;
    private var grid:Vector<Vector<TileNode>>;
    private var connections:Map<TileType, Array<Bool>>;

    public function new()
    {
        super();

        grid = new Vector<Vector<TileNode>>(GridConfig.width);

        for(i in 0...GridConfig.width)
        {
            grid[i] = new Vector<TileNode>(GridConfig.height);
        }

        connections = new Map<TileType, Array<Bool>>();

        connections[TileType.EMPTY] = [false, false, false, false];
        connections[TileType.L] = [true, false, false, true];
        connections[TileType.I] = [false, true, false, true];
    }

    override public function addToEngine(_engine:Engine)
    {
        engine = _engine;
        var list = engine.getNodeList(TileNode);

        for(node in list)
        {
            var p = node.tile.position;
            grid[p.x][p.y] = node;
        }
    }

    private inline function areTilesConnected(first:Tile, second:Tile)
    {
        var p1 = first.position;
        var p2 = second.position;
    }

    private inline function getDirectionState(tile:Tile, direction:Int)
    {
        direction += Std.int(tile.angle / 90);

        while(direction < 0)
        {
            direction += 4;
        }

        while(direction >= 4)
        {
            direction -= 4;
        }

        return connections[tile.type][direction];
    }
}
