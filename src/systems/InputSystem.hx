package systems;

import gengine.*;
import gengine.components.*;
import ash.systems.*;
import ash.fsm.*;
import components.*;
import nodes.*;
import gengine.math.*;
import haxe.ds.Vector;

class InputSystem extends System
{
    private var engine:Engine;
    private var cameraEntity:Entity;
    private var grid:Vector<Vector<TileNode>>;
    private var selectedTileNode:TileNode;

    public function new(cameraEntity_:Entity)
    {
        super();
        cameraEntity = cameraEntity_;

        grid = new Vector<Vector<TileNode>>(GridConfig.width);

        for(i in 0...GridConfig.width)
        {
            grid[i] = new Vector<TileNode>(GridConfig.height);
        }
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

    override public function update(dt:Float):Void
    {
        var input = Gengine.getInput();
        var mousePosition = input.getMousePosition();
        var mouseScreenPosition = new Vector2(mousePosition.x / 1024, mousePosition.y / 768);
        var mouseWorldPosition = cameraEntity.get(Camera).screenToWorldPoint(new Vector3(mouseScreenPosition.x, mouseScreenPosition.y, 0));

        if(selectedTileNode != null)
        {
            selectedTileNode.sprite.setAlpha(1.0);
            selectedTileNode = null;
        }

        {
            var offset = GridConfig.offset;
            var tileSize = GridConfig.tileSize;
            var p = new IntVector2(Std.int((mouseWorldPosition.x - offset.x + tileSize/2) / tileSize), Std.int((mouseWorldPosition.y - offset.y + tileSize/2) / tileSize));

            if(p.x >= 0 && p.y >= 0 && p.x < GridConfig.width && p.y < GridConfig.height)
            {
                selectedTileNode = grid[p.x][p.y];
                selectedTileNode.sprite.setAlpha(0.5);

                if(input.getMouseButtonPress(1))
                {
                    selectedTileNode.tile.sm.changeState("moving");

                    var tm:TileMovement = selectedTileNode.entity.get(TileMovement);

                    tm.from = null;
                    tm.to = null;
                    tm.duration = 0.25;
                    tm.fromAngle = selectedTileNode.tile.angle;
                    tm.toAngle = tm.fromAngle - 90;

                    Application.esm.changeState("gameRotating");
                }
            }
        }
    }
}
