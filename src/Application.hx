import gengine.*;
import gengine.math.*;
import gengine.components.*;
import gengine.graphics.*;

import nodes.*;

import ash.fsm.*;

import systems.*;
import js.jquery.*;
import js.UIPages;
import js.PagesSet;

class Application
{
    private static var engine:Engine;
    private static var esm:EngineStateMachine;
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
        Gengine.getRenderer().getDefaultZone().setFogColor(new Color(0.8, 0.9, 0.8, 1));
        var gameSystem = new GameSystem();
        var tileMovementSystem = new TileMovementSystem();
        var clockSystem = new ClockSystem(gameSystem);
        var cameraEntity = new Entity();
        cameraEntity.add(new Camera());
        cameraEntity.get(Camera).setOrthoSize(new Vector2(1024, 768));
        cameraEntity.get(Camera).setOrthographic(true);
        engine.addEntity(cameraEntity);
        esm = new EngineStateMachine(engine);
        state = new EngineState();
        state.addInstance(new MenuSystem());
        esm.addState("menu", state);
        state = new EngineState();
        state.addInstance(gameSystem);
        state.addInstance(new FillSystem());
        state.addInstance(tileMovementSystem);
        esm.addState("gameFalling", state);
        state = new EngineState();
        state.addInstance(gameSystem);
        state.addInstance(new MatchSystem());
        esm.addState("gameMatching", state);
        state = new EngineState();
        state.addInstance(gameSystem);
        state.addInstance(new InputSystem(cameraEntity));
        state.addInstance(clockSystem);
        esm.addState("gameIdling", state);
        state = new EngineState();
        state.addInstance(gameSystem);
        state.addInstance(tileMovementSystem);
        esm.addState("gameRotating", state);
        esm.changeState("menu");
        Factory.init();
        var border:Entity;
        border = Factory.createBorder(new IntVector2(1024, 1024));
        border.position = new Vector3(0, 0, 0);
        engine.addEntity(border);
        engine.addSystem(new AudioSystem(), 10);
        changeState("menu");
    }

    public static function onGuiLoaded()
    {
        pages = UIPages.createSet(new JQuery("#body"));
        pages.showPage(".menu");
        engine.getSystem(MenuSystem).init();
    }

    public static function changeState(stateName)
    {
        engine.updateComplete.addOnce(function()
        {
            esm.changeState(stateName);
        });
    }


    public static function newGame()
    {
        var nodeList = engine.getNodeList(TileNode);
        var entityList = new Array<Entity>();
        for(t in nodeList)
        {
            entityList.push(t.entity);
        }
        for(e in entityList)
        {
            engine.removeEntity(e);
        }

        changeState("gameFalling");
    }
}
