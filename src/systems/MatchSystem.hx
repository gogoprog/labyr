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
    private var matches:Map<TileNode, Bool> = new Map();
    private var matchesList:Array<TileNode> = new Array<TileNode>();
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
        connections[TileType.T] = [true, true, false, true];
        connections[TileType.POWERUP] = [true, true, true, true];
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
        if(findMatches())
        {
            disappearTiles();
            engine.getSystem(AudioSystem).playSound("match");
        }
        else
        {
            // trace("Possibilities : " + countPossibleMatches());
        }
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
            engine.removeEntity(e);
            Factory.onItemRemoved(e);
        }
        entitiesToRemove.splice(0, entitiesToRemove.length);
        if(matchesList.length > 0)
        {
            engine.getSystem(AudioSystem).playSound("match");
            matchesList = [];
            matches = new Map();
            return;
        }
        if(nodeList.empty && !itMustRepopulate)
        {
            Application.changeState("gameIdling");
            return;
        }
        if(itMustRepopulate)
        {
            Application.changeState("gameFalling");
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
        for(x in 0...GridConfig.width)
        {
            for(y in 0...GridConfig.height)
            {
                var tn = grid[x][y];
                findPath(tn, [tn => true], [tn], -1);
            }
        }
        return matchesList.length > 0;
    }

    private function disappearTiles()
    {
        for(tileNode in matchesList)
        {
            tileNode.disappear();
        }
        if(matchesList.length > 0)
        {
            pathFinder = new Pathfinder(this);
            for(x in 0...GridConfig.width)
            {
                for(y in 0...GridConfig.height)
                {
                    var tn = grid[x][y];
                    if(!tn.tile.matching)
                    {
                        var reachable:Bool;
                        reachable = true;
                        for(x2 in 0...x)
                        {
                            if(grid[x2][y].tile.matching)
                            {
                                reachable = false;
                                break;
                            }
                        }
                        if(reachable)
                        {
                            continue;
                        }
                        reachable = true;
                        for(x2 in x...GridConfig.width)
                        {
                            if(grid[x2][y].tile.matching)
                            {
                                reachable = false;
                                break;
                            }
                        }
                        if(reachable)
                        {
                            continue;
                        }
                        reachable = true;
                        for(y2 in 0...y)
                        {
                            if(grid[x][y2].tile.matching)
                            {
                                reachable = false;
                                break;
                            }
                        }
                        if(reachable)
                        {
                            continue;
                        }
                        reachable = true;
                        for(y2 in y...GridConfig.height)
                        {
                            if(grid[x][y2].tile.matching)
                            {
                                reachable = false;
                                break;
                            }
                        }
                        if(reachable)
                        {
                            continue;
                        }
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
                                tn.disappear();
                            }
                        }
                    }
                }
            }
            matches = new Map();
            matchesList = [];
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

    private function getTileNode(x:Int, y:Int):TileNode
    {
        var p2:IntVector2;

        p2 = new IntVector2(x, y);

        if(isTile(p2))
        {
            var tileNode2 = grid[p2.x][p2.y];
            return tileNode2;
        }

        return null;
    }

    private function getNeighborTileNode(tile:Tile, offsetX:Int, offsetY:Int):TileNode
    {
        var p = tile.position;
        var p2:IntVector2;

        p2 = new IntVector2(p.x + offsetX, p.y + offsetY);

        if(isTile(p2))
        {
            var tileNode2 = grid[p2.x][p2.y];
            return tileNode2;
        }

        return null;
    }

    private function getConnectedTileNode(tile:Tile, direction:Int):TileNode
    {
        var p = tile.position;
        var p2:IntVector2;

        if(isDirectionOpen(tile, direction))
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
                otherTileNode = getConnectedTileNode(tileNode.tile, d);
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
                            if(!matches.exists(tileNode))
                            {
                                matches[tileNode] = true;
                                matchesList.push(tileNode);
                            }
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
            if(tdn.tile.powerup != null)
            {
                switch(tdn.tile.powerup)
                {
                    case ABOMB:
                        addMatch(getNeighborTileNode(tdn.tile, 0, 1));
                        addMatch(getNeighborTileNode(tdn.tile, 0, -1));
                        addMatch(getNeighborTileNode(tdn.tile, 1, 0));
                        addMatch(getNeighborTileNode(tdn.tile, -1, 0));
                        addMatch(getNeighborTileNode(tdn.tile, -1, 1));
                        addMatch(getNeighborTileNode(tdn.tile, -1, -1));
                        addMatch(getNeighborTileNode(tdn.tile, 1, 1));
                        addMatch(getNeighborTileNode(tdn.tile, 1, -1));
                    case HBOMB:
                        var y = tdn.tile.position.y;
                        for(x in 0...GridConfig.width)
                        {
                            addMatch(getTileNode(x, y));
                        }
                    case VBOMB:
                        var x = tdn.tile.position.x;
                        for(y in 0...GridConfig.height)
                        {
                            addMatch(getTileNode(x, y));
                        }
                    case XBOMB:
                        var x = tdn.tile.position.x;
                        var y = tdn.tile.position.y;
                        for(i in 1...GridConfig.width * 2)
                        {
                            addMatch(getTileNode(x + i, y + i));
                            addMatch(getTileNode(x - i, y + i));
                            addMatch(getTileNode(x + i, y - i));
                            addMatch(getTileNode(x - i, y - i));
                        }
                }
            }
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

    private function addMatch(tn:TileNode)
    {
        if(tn == null) {return;}
        if(!matches.exists(tn))
        {
            matches[tn] = true;
            matchesList.push(tn);
            tn.disappear();
        }
    }

    private function countPossibleMatches()
    {
        var result = 0;
        for(i in 0...GridConfig.width)
        {
            for(j in 0...GridConfig.height)
            {
                var tn = grid[i][j];
                for(r in 0...3)
                {
                    tn.tile.angle += 90;
                    if(findMatches())
                    {
                        ++result;
                    }
                }
                tn.tile.angle -= 270;
            }
        }
        return result;
    }
}
