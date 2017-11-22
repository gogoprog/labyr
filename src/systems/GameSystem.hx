package systems;

import gengine.*;
import gengine.components.*;
import ash.systems.*;
import ash.fsm.*;
import components.*;
import gengine.math.*;
import components.Tile.TileType;
import ash.signals.*;
import nodes.*;

class GameSystem extends System
{
    private var engine:Engine;
    public var gameStarted:Signal1<Level> = new Signal1<Level>();

    public function new()
    {
        super();
    }

    override public function addToEngine(_engine:Engine)
    {
        engine = _engine;
        var level = {time: 10.9};
        gameStarted.dispatch(level);
    }

    override public function update(dt:Float):Void
    {
        var input = Gengine.getInput();

        if(input.getScancodePress(41))
        {
            Application.changeState("menu");
            Application.pages.showPage(".menu");
        }
    }
}
