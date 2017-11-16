package systems;

import gengine.*;
import gengine.components.*;
import ash.systems.*;
import ash.fsm.*;
import components.*;
import gengine.math.*;
import haxe.ds.Vector;
import js.jquery.JQuery;

class ClockSystem extends System
{
    private var engine:Engine;
    private var timeLeft:Float;
    private var secondLeft:Int = 0;
    private var timerElement:JQuery;

    public function new(gameSystem:GameSystem)
    {
        super();
        gameSystem.gameStarted.add(onGameStarted);
    }

    override public function addToEngine(_engine:Engine)
    {
        engine = _engine;
        timerElement = new JQuery("#timer");
    }

    override public function update(dt:Float)
    {
        timeLeft -= dt;

        var seconds:Int = Math.floor(timeLeft);
        if(secondLeft != seconds)
        {
            secondLeft = seconds;
            timerElement.text(seconds);
        }

        if(timeLeft < 0)
        {
            Application.changeState("menu");
            Application.pages.showPage(".menu");
        }
    }

    private function onGameStarted(level:Level)
    {
        timeLeft = level.time;
    }
}

