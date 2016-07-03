package systems;

import gengine.*;
import ash.systems.*;

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
    }

    override public function update(dt:Float):Void
    {
        var input = Gengine.getInput();

        if(input.getScancodePress(41))
        {
            Application.esm.changeState("Menu");
        }
    }
}
