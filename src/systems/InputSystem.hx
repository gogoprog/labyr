package systems;

import gengine.*;
import gengine.components.*;
import ash.systems.*;
import ash.fsm.*;
import components.*;
import gengine.math.*;

class InputSystem extends System
{
    private var engine:Engine;
    private var cameraEntity:Entity;

    public function new(cameraEntity_:Entity)
    {
        super();
        cameraEntity = cameraEntity_;
    }

    override public function addToEngine(_engine:Engine)
    {
        engine = _engine;
    }

    override public function update(dt:Float):Void
    {
        var input = Gengine.getInput();

        if(input.getMouseButtonPress(1))
        {
            trace("InputSystem");
        }
    }


}
