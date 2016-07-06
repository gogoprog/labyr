package systems;

import ash.tools.ListIteratingSystem;

import components.*;
import nodes.*;
import gengine.math.*;

class TileMovementSystem extends ListIteratingSystem<TileMovementNode>
{
    public function new()
    {
        super(TileMovementNode, updateNode, onNodeAdded, onNodeRemoved);
    }

    private function updateNode(node:TileMovementNode, dt:Float):Void
    {
        var tm = node.tileMovement;
        var from = tm.from;
        var to = tm.to;
        tm.time += dt;

        var factor = tm.time / tm.duration;

        node.entity.position = new Vector3(
            from.x + (to.x - from.x) * factor,
            from.y + (to.y - from.y) * factor,
            0
            );

        if(factor > 1)
        {
            node.entity.position = new Vector3(to.x, to.y, 0);
            node.tile.sm.changeState("idle");
        }
    }

    private function onNodeAdded(node:TileMovementNode)
    {

    }

    private function onNodeRemoved(node:TileMovementNode)
    {
        if(nodeList.empty)
        {
            Application.esm.changeState("gameIdling");
        }
    }
}
