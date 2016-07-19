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
        var fromAngle = tm.fromAngle;
        var toAngle = tm.toAngle;
        tm.time += dt;

        var factor = tm.time / tm.duration;

        if(from != null)
        {
            node.entity.position = new Vector3(
                from.x + (to.x - from.x) * easeIn(factor),
                from.y + (to.y - from.y) * easeIn(factor),
                0
                );
        }

        if(toAngle != null)
        {
            node.entity.setRotation2D(fromAngle + (toAngle - fromAngle) * easeIn(factor));
        }

        if(factor > 1)
        {
            if(from != null)
            {
                node.entity.position = new Vector3(to.x, to.y, 0);
            }

            if(toAngle != null)
            {
                while(toAngle < 0)
                {
                    toAngle += 360;
                }

                while(toAngle >= 360)
                {
                    toAngle -= 360;
                }

                node.entity.setRotation2D(toAngle);
                node.tile.angle = toAngle;
            }

            node.tile.sm.changeState("idle");
        }
    }

    private function onNodeAdded(node:TileMovementNode)
    {
        node.tileMovement.time = 0;
    }

    private function onNodeRemoved(node:TileMovementNode)
    {
        if(nodeList.empty)
        {
            Application.esm.changeState("gameMatching");
        }
    }

    static function easeIn(f:Float)
    {
        return 1.0 - Math.cos(f * Math.PI * 0.5);
    };
}
