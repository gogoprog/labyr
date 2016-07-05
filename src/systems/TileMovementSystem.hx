package systems;

import ash.tools.ListIteratingSystem;

import components.*;
import nodes.*;
import gengine.math.*;

class TileMovementSystem extends ListIteratingSystem<TileMovementNode>
{
    public function new()
    {
        super(TileMovementNode, updateNode, null);
    }

    private function updateNode(node:TileMovementNode, dt:Float):Void
    {
        var tm = node.tileMovement;
        var from = tm.from;
        var to = tm.to;

        tm.factor += dt;

        node.entity.position = new Vector3(
            from.x + (to.x - from.x) * tm.factor,
            from.y + (to.y - from.y) * tm.factor,
            0
            );

        if(tm.factor > 1)
        {
            node.entity.position = new Vector3(to.x, to.y, 0);
            node.tile.sm.changeState("idle");
        }
    }
}
