package systems;

import gengine.*;
import ash.systems.*;
import js.*;

@:expose('Menu')
class MenuSystem extends System
{
    private var engine:Engine;

    public function new()
    {
        super();
        init();
    }

    public function init()
    {
        new JQuery(".startButton").click(onStartClick);
        new JQuery(".quitButton").click(onQuitClick);
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
            trace("Labyr exit.");
            Gengine.exit();
        }
    }

    private function onStartClick()
    {
        trace("onStartClick");

        Application.esm.changeState("Game");
        Application.pages.showPage(".hud");
    }

    private function onQuitClick()
    {
        trace("Labyr exit.");
        Gengine.exit();
    }
}
