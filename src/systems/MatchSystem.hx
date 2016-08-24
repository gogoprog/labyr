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

class MatchSystem extends ListIteratingSystem<TileDisappearingNode> implements IMap
{
    public var cols = GridConfig.width + 2;
    public var rows = GridConfig.height + 2;

    private var engine:Engine;
    private var grid:Vector<Vector<TileNode>>;
    private var connections:Map<TileType, Array<Bool>>;
    private var matches:Map<TileNode, Bool>;
    private var count:Int;
    private var itMustRepopulate = false;
    private var pathFinder:Pathfinder;

    private var entitiesToRemove = new Array<Entity>();

    public function new()
    {
        super(TileDisappearingNode, updateNode, onNodeAdded, onNodeRemoved);

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
        super.addToEngine(_engine);

        engine = _engine;
        var list = engine.getNodeList(TileNode);

        for(node in list)
        {
            var p = node.tile.position;
            grid[p.x][p.y] = node;
        }

        findMatches();
    }

    override public function removeFromEngine(_engine:Engine)
    {
        super.removeFromEngine(_engine);
    }

    override public function update(dt:Float)
    {
        super.update(dt);

        for(i in 0...entitiesToRemove.length)
        {
            var e = entitiesToRemove[i];
            e.get(Tile).sm.changeState("idle");

            if(e.has(TileDisappearing))
            {
                untyped __js__("Error.stackTraceLimit = Infinity; var stack = new Error('e.has(TileDisappearing) in removal').stack;  console.log( stack );");
            }

            engine.removeEntity(e);
            Factory.onItemRemoved(e);
        }

        entitiesToRemove.splice(0, entitiesToRemove.length);

        if(count == 0)
        {
            Application.esm.changeState("gameIdling");
            return;
        }

        if(itMustRepopulate)
        {
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
                        e.get(TileMovement).from = new Vector2(offset.x + i * GridConfig.tileSize, offset.y + j * GridConfig.tileSize);
                        e.get(TileMovement).to = new Vector2(offset.x + i * GridConfig.tileSize, offset.y + (j - holes) * GridConfig.tileSize);
                        e.get(TileMovement).duration = 0.02 * holes;
                        e.get(TileMovement).fromAngle = e.get(Tile).angle;
                        e.get(TileMovement).toAngle = e.get(Tile).angle;
                    }
                }

                for(h in 0...holes)
                {
                    var e = Factory.getItem(Std.random(2) + 1, Std.random(4) * 90);

                    e.get(Tile).sm.changeState("moving");
                    e.get(Tile).position = new IntVector2(i, GridConfig.height - holes + h);
                    e.get(TileMovement).from = new Vector2(offset.x + i * GridConfig.tileSize, offset.y + (GridConfig.height + h ) * GridConfig.tileSize);
                    e.get(TileMovement).to = new Vector2(offset.x + i * GridConfig.tileSize, offset.y + (GridConfig.height - holes + h) * GridConfig.tileSize);
                    e.get(TileMovement).duration = 0.02 * holes;
                    e.get(TileMovement).fromAngle = e.get(Tile).angle;
                    e.get(TileMovement).toAngle = e.get(Tile).angle;

                    e.position = new Vector3(offset.x + i * GridConfig.tileSize, offset.y + (GridConfig.height + h ) * GridConfig.tileSize, 0);

                    if(e.has(TileDisappearing))
                    {
                        untyped __js__("Error.stackTraceLimit = Infinity; var stack = new Error('e.has(TileDisappearing) in populate').stack;  console.log( stack );");
                    }

                    engine.addEntity(e);
                }
            }

            Application.esm.changeState("gameFalling");
            itMustRepopulate = false;
        }
    }

    public function isWalkable(x:Int, y:Int):Bool
    {
        if(x == 0 || y == 0 || x == GridConfig.width + 1 || y == GridConfig.height + 1)
        {
            return true;
        }

        return !grid[x - 1][y - 1].tile.matching;
    }

    private function findMatches()
    {
        matches = new Map<TileNode, Bool>();

        for(x in 0...GridConfig.width)
        {
            for(y in 0...GridConfig.height)
            {
                var tn = grid[x][y];
                tn.sprite.setColor(new Color(1.0,1.0,1.0,1.0));
                findPath(tn, [tn => true], [tn], -1);
            }
        }

        count = [for (k in matches.keys()) k].length;

        for(tileNode in matches.keys())
        {
            tileNode.sprite.setColor(new Color(0.0,0.0,1.0,1.0));
            tileNode.tile.sm.changeState("disappearing");
            tileNode.tile.matching = true;
        }

        if(count > 0)
        {
            pathFinder = new Pathfinder(this);

            for(x in 0...GridConfig.width)
            {
                for(y in 0...GridConfig.height)
                {
                    var tn = grid[x][y];
                    if(!tn.tile.matching)
                    {
                        var path = pathFinder.createPath(
                            new Coordinate(x+1, y+1),
                            new Coordinate(0, 0),
                            EHeuristic.PRODUCT,
                            false,
                            false
                            );

                        if(path == null)
                        {
                            tn.sprite.setColor(new Color(1.0,0.0,1.0,1.0));
                            tn.tile.sm.changeState("disappearing");
                            tn.tile.matching = true;
                        }
                        else
                        {

                        }
                    }
                }
            }
        }
    }

    private inline function areTilesConnected(first:Tile, second:Tile)
    {
        var p1 = first.position;
        var p2 = second.position;

        if(p1.x == p2.x)
        {
            if(p2.y - p1.y == 1)
            {
                return isDirectionOpen(first, 0) && isDirectionOpen(second, 2);
            }
            else if(p1.y - p2.y == 1)
            {
                return isDirectionOpen(first, 2) && isDirectionOpen(second, 0);
            }
        }
        else if(p1.y == p2.y)
        {
            if(p2.x - p1.x == 1)
            {
                return isDirectionOpen(first, 1) && isDirectionOpen(second, 3);
            }
            else if(p1.x - p2.x == 1)
            {
                return isDirectionOpen(first, 3) && isDirectionOpen(second, 1);
            }
        }

        return false;
    }

    private inline function isDirectionOpen(tile:Tile, direction:Int)
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

    private inline function isTile(p:IntVector2)
    {
        return p.x >= 0 && p.y >= 0 && p.x < GridConfig.width && p.y < GridConfig.height;
    }

    private function getConnectedTileNode(tileNode:TileNode, direction:Int):TileNode
    {
        var p = tileNode.tile.position;
        var p2:IntVector2;

        if(isDirectionOpen(tileNode.tile, direction))
        {
            switch(direction)
            {
                case 0:
                    p2 = new IntVector2(p.x, p.y + 1);
                case 1:
                    p2 = new IntVector2(p.x + 1, p.y);
                case 2:
                    p2 = new IntVector2(p.x, p.y - 1);
                case 3:
                    p2 = new IntVector2(p.x - 1, p.y);
                default:
                    p2 = new IntVector2(666, 666);
            }

            if(isTile(p2))
            {
                var tileNode2 = grid[p2.x][p2.y];

                if(isDirectionOpen(tileNode2.tile, (direction + 2) % 4))
                {
                    return tileNode2;
                }
            }
        }

        return null;
    }

    private function findPath(tileNode:TileNode, path:Map<TileNode, Bool>, orderedPath:Array<TileNode>, previousDirection:Int)
    {
        var otherTileNode:TileNode;
        var finished = false;

        for(d in 0...4)
        {
            if(d != (previousDirection + 2) % 4)
            {
                otherTileNode = getConnectedTileNode(tileNode, d);

                if(otherTileNode != null)
                {
                    if(!path.exists(otherTileNode))
                    {
                        var otherPath = new Map<TileNode, Bool>();
                        var otherOrderedPath = new Array<TileNode>();

                        for(k in orderedPath)
                        {
                            otherPath[k] = path[k];
                            otherOrderedPath.push(k);
                        }

                        otherPath[otherTileNode] = true;
                        otherOrderedPath.push(otherTileNode);

                        findPath(otherTileNode, otherPath, otherOrderedPath, d);
                        finished = false;
                    }
                    else if(otherTileNode == orderedPath[0])
                    {
                        for(tileNode in path.keys())
                        {
                            matches[tileNode] = true;
                        }
                    }
                }
            }
        }
    }

    private function updateNode(tdn:TileDisappearingNode, dt:Float)
    {
        tdn.tileDisappearing.time += dt;

        tdn.sprite.setAlpha(1.0 - tdn.tileDisappearing.time * 6);

        if(tdn.tileDisappearing.time > 0.5)
        {
            entitiesToRemove.push(tdn.entity);
        }
    }

    private function onNodeAdded(tdn:TileDisappearingNode)
    {
        tdn.tileDisappearing.time = 0;
    }

    private function onNodeRemoved(tdn:TileDisappearingNode)
    {
        var p = tdn.tile.position;
        grid[p.x][p.y] = null;

        if(engine.getNodeList(TileDisappearingNode).empty)
        {
            itMustRepopulate = true;
        }
    }
}
