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
        var state:EngineState;
        engine = _engine;

        var cameraEntity = new Entity();
        cameraEntity.add(new Camera());
        cameraEntity.get(Camera).setOrthoSize(new Vector2(1024, 768));
        cameraEntity.get(Camera).setOrthographic(true);
        engine.addEntity(cameraEntity);

        esm = new EngineStateMachine(engine);

        state = new EngineState();
        state.addInstance(new MenuSystem());
        esm.addState("menu", state);

        var gameSystem = new GameSystem();

        state = new EngineState();
        state.addInstance(gameSystem);
        state.addInstance(new TileMovementSystem());
        esm.addState("gameFalling", state);

        state = new EngineState();
        state.addInstance(gameSystem);
        state.addInstance(new InputSystem(cameraEntity));
        esm.addState("gameIdling", state);

        state = new EngineState();
        state.addInstance(gameSystem);
        esm.addState("gameRotating", state);

        esm.changeState("menu");

        pages = UIPages.createSet(new JQuery("#body"));

        pages.showPage(".menu");
    }
}
