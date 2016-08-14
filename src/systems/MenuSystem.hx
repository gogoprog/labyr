package systems;

import gengine.*;
import ash.systems.*;
import js.jquery.JQuery;

@:expose('Menu')
class MenuSystem extends System
{
    private var engine:Engine;

    public function new()
    {
        super();
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

    private function onStartClick(event)
    {
        Application.esm.changeState("gameFalling");
        Application.pages.showPage(".hud");
    }

    private function onQuitClick(event)
    {
        trace("Labyr exit.");
        Gengine.exit();
    }
}
