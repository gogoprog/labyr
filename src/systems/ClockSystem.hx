package systems;

import gengine.*;
import gengine.components.*;
import ash.systems.*;
import ash.fsm.*;
import components.*;
import gengine.math.*;
import haxe.ds.Vector;

class ClockSystem extends System
{
    private var engine:Engine;
    private var timeLeft:Float;

    public function new(gameSystem:GameSystem)
    {
        super();
        gameSystem.gameStarted.add(onGameStarted);
    }

    override public function addToEngine(_engine:Engine)
    {
        engine = _engine;
    }

    override public function update(dt:Float)
    {
        timeLeft -= dt;
        trace(timeLeft);
    }

    private function onGameStarted(level:Level)
    {

    }
}

