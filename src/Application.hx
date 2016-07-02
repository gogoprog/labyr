import gengine.*;
import gengine.math.*;
import gengine.components.*;
import gengine.graphics.*;

import ash.fsm.*;

import systems.*;
import js.*;

class Application
{
    private static var engine:Engine;
    public static var esm:EngineStateMachine;
    public static var pages:PagesSet;

    public static function init()
    {
        trace("Labyr init");
        Gengine.setWindowSize(new IntVector2(1024, 768));
        Gengine.setWindowTitle("Labyr");
        Gengine.setGuiFilename("gui/gui.html");
    }

    public static function start(_engine:Engine)
    {
        engine = _engine;

        esm = new EngineStateMachine(engine);

        var menuState = new EngineState();
        menuState.addInstance(new MenuSystem());
        esm.addState("Menu", menuState);

        var gameState = new EngineState();
        esm.addState("Game", gameState);

        esm.changeState("Menu");

        pages = UIPages.createSet(new JQuery("#body"));

        pages.showPage(".menu");
    }
}
